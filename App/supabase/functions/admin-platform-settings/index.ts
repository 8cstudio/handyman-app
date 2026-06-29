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
        .from("platform_settings")
        .select("*")
        .limit(1)
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ settings: data });
    }

    if (req.method === "PUT") {
      const body = await req.json();
      const { platform_name, theme_config } = body;

      const updates: Record<string, unknown> = {
        updated_at: new Date().toISOString(),
        updated_by: user.id,
      };
      if (platform_name) updates.platform_name = platform_name;
      if (theme_config) updates.theme_config = theme_config;

      const { data, error } = await serviceClient
        .from("platform_settings")
        .update(updates)
        .select("*")
        .limit(1)
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ settings: data });
    }

    return errorResponse("Method not allowed", 405);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
