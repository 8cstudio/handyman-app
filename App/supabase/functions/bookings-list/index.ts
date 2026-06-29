import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
  requireRole,
} from "../_shared/utils.ts";

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const roleCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin", "customer", "provider"]);
  if (roleCheck instanceof Response) return roleCheck;
  const { profile } = roleCheck;

  const serviceClient = getServiceClient();

  try {
    if (req.method === "GET") {
      const url = new URL(req.url);
      const status = url.searchParams.get("status");
      const page = Math.max(0, parseInt(url.searchParams.get("page") ?? "0", 10));
      const pageSize = Math.min(
        100,
        Math.max(1, parseInt(url.searchParams.get("page_size") ?? "20", 10))
      );

      let query = serviceClient
        .from("bookings")
        .select(`
          *,
          services(name, price, duration_minutes),
          customers(profiles(full_name, phone)),
          providers(profiles(full_name, phone))
        `)
        .order("created_at", { ascending: false });

      if (status) query = query.eq("status", status);

      if (profile.role === "company_admin") {
        query = query.eq("company_id", profile.company_id);
      } else if (profile.role === "customer") {
        const { data: customer } = await serviceClient
          .from("customers")
          .select("id")
          .eq("user_id", user.id)
          .single();
        if (customer) query = query.eq("customer_id", customer.id);
      } else if (profile.role === "provider") {
        const { data: provider } = await serviceClient
          .from("providers")
          .select("id")
          .eq("user_id", user.id)
          .single();
        if (provider) query = query.eq("provider_id", provider.id);
      }

      const from = page * pageSize;
      const to = from + pageSize;
      const { data, error } = await query.range(from, to);
      if (error) throw new Error(error.message);

      const rows = data ?? [];
      const hasMore = rows.length > pageSize;
      const bookings = hasMore ? rows.slice(0, pageSize) : rows;
      return jsonResponse({ bookings, has_more: hasMore });
    }

    return errorResponse("Method not allowed", 405);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
