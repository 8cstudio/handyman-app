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

  const roleCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
  if (roleCheck instanceof Response) return roleCheck;
  const { profile } = roleCheck;

  const companyId = profile.role === "super_admin"
    ? (await req.clone().json().catch(() => ({}))).company_id
    : profile.company_id;

  const serviceClient = getServiceClient();

  try {
    if (req.method === "GET") {
      const url = new URL(req.url);
      const cid = url.searchParams.get("company_id") ?? companyId;
      const { data, error } = await serviceClient
        .from("categories")
        .select("*")
        .eq("company_id", cid)
        .order("sort_order");
      if (error) throw new Error(error.message);
      return jsonResponse({ categories: data });
    }

    const body = await req.json();
    const cid = body.company_id ?? companyId;

    if (req.method === "POST") {
      const { name, description, image_url, sort_order } = body;
      if (!name || !cid) return errorResponse("name and company_id are required");

      const { data, error } = await serviceClient
        .from("categories")
        .insert({ company_id: cid, name, description, image_url, sort_order: sort_order ?? 0 })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ category: data }, 201);
    }

    if (req.method === "PUT") {
      const { id, ...updates } = body;
      if (!id) return errorResponse("id is required");

      const { data, error } = await serviceClient
        .from("categories")
        .update(updates)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ category: data });
    }

    if (req.method === "DELETE") {
      const { id } = body;
      if (!id) return errorResponse("id is required");

      const { error } = await serviceClient.from("categories").delete().eq("id", id);
      if (error) throw new Error(error.message);
      return jsonResponse({ success: true });
    }

    return errorResponse("Method not allowed", 405);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
