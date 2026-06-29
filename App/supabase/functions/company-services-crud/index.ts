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
      const companyId = url.searchParams.get("company_id") ?? profile.company_id;
      const categoryId = url.searchParams.get("category_id");
      const search = url.searchParams.get("search");

      let query = serviceClient
        .from("services")
        .select("*, categories(name)")
        .eq("is_active", true);

      if (companyId) query = query.eq("company_id", companyId);
      if (categoryId) query = query.eq("category_id", categoryId);
      if (search) query = query.ilike("name", `%${search}%`);

      const { data, error } = await query.order("name");
      if (error) throw new Error(error.message);
      return jsonResponse({ services: data });
    }

    const roleCheckWrite = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
    if (roleCheckWrite instanceof Response) return roleCheckWrite;

    const body = await req.json();
    const companyId = body.company_id ?? profile.company_id;

    if (req.method === "POST") {
      const { category_id, name, description, price, duration_minutes, image_url } = body;
      if (!category_id || !name || !companyId) {
        return errorResponse("category_id, name, and company_id are required");
      }

      const { data, error } = await serviceClient
        .from("services")
        .insert({
          company_id: companyId,
          category_id,
          name,
          description,
          price: price ?? 0,
          duration_minutes: duration_minutes ?? 60,
          image_url,
        })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ service: data }, 201);
    }

    if (req.method === "PUT") {
      const { id, ...updates } = body;
      if (!id) return errorResponse("id is required");

      const { data, error } = await serviceClient
        .from("services")
        .update(updates)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ service: data });
    }

    if (req.method === "DELETE") {
      const { id } = body;
      if (!id) return errorResponse("id is required");

      const { error } = await serviceClient
        .from("services")
        .update({ is_active: false })
        .eq("id", id);
      if (error) throw new Error(error.message);
      return jsonResponse({ success: true });
    }

    return errorResponse("Method not allowed", 405);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
