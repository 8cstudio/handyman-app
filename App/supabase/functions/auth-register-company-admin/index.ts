import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  errorResponse,
  getServiceClient,
  handleCors,
  jsonResponse,
  requireRole,
  getAuthUser,
} from "../_shared/utils.ts";

interface CreateAdminBody {
  email: string;
  password: string;
  full_name: string;
  phone?: string;
  company_id: string;
}

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const roleCheck = await requireRole(auth.client, user.id, ["super_admin"]);
  if (roleCheck instanceof Response) return roleCheck;

  try {
    const body: CreateAdminBody = await req.json();
    const { email, password, full_name, phone, company_id } = body;

    if (!email || !password || !full_name || !company_id) {
      return errorResponse("email, password, full_name, and company_id are required");
    }

    const serviceClient = getServiceClient();

    const { data: authData, error: authError } = await serviceClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name, role: "company_admin" },
    });

    if (authError) return errorResponse(authError.message, 400);

    const userId = authData.user!.id;

    await serviceClient.from("profiles").insert({
      id: userId,
      role: "company_admin",
      full_name,
      phone: phone ?? null,
      company_id,
    });

    await serviceClient.from("company_admins").insert({
      user_id: userId,
      company_id,
    });

    return jsonResponse({
      user: { id: userId, email, full_name, role: "company_admin", company_id },
    }, 201);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
