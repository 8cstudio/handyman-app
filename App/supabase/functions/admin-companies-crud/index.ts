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

  const roleCheck = await requireRole(auth.client, user.id, ["super_admin"]);
  if (roleCheck instanceof Response) return roleCheck;

  const serviceClient = getServiceClient();

  try {
    if (req.method === "GET") {
      const { data, error } = await serviceClient
        .from("companies")
        .select("*")
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return jsonResponse({ companies: data });
    }

    if (req.method === "POST") {
      const body = await req.json();
      const { name, description, email, phone, address } = body;
      if (!name) return errorResponse("name is required");

      const { data, error } = await serviceClient
        .from("companies")
        .insert({ name, description, email, phone, address })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ company: data }, 201);
    }

    if (req.method === "PUT") {
      const body = await req.json();
      const { id, ...updates } = body;
      if (!id) return errorResponse("id is required");

      const { data, error } = await serviceClient
        .from("companies")
        .update(updates)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ company: data });
    }

    if (req.method === "DELETE") {
      const { id } = await req.json();
      if (!id) return errorResponse("id is required");

      const { error } = await serviceClient
        .from("companies")
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
