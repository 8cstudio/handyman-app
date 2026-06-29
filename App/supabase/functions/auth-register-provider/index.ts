import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
  requireRole,
} from "../_shared/utils.ts";

interface RegisterProviderBody {
  email: string;
  password: string;
  full_name: string;
  phone?: string;
  company_id?: string;
  skills?: string[];
  experience_years?: number;
  bio?: string;
}

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const roleCheck = await requireRole(auth.client, user.id, [
    "super_admin",
    "company_admin",
  ]);
  if (roleCheck instanceof Response) return roleCheck;
  const { profile } = roleCheck;

  try {
    const body: RegisterProviderBody = await req.json();
    const {
      email,
      password,
      full_name,
      phone,
      company_id,
      skills,
      experience_years,
      bio,
    } = body;

    const resolvedCompanyId =
      profile.role === "company_admin"
        ? (profile.company_id as string)
        : company_id;

    if (!email || !password || !full_name || !resolvedCompanyId) {
      return errorResponse(
        "email, password, full_name, and company_id are required",
        400
      );
    }

    const serviceClient = getServiceClient();

    const { data: company } = await serviceClient
      .from("companies")
      .select("id, is_active")
      .eq("id", resolvedCompanyId)
      .single();

    if (!company || !company.is_active) {
      return errorResponse("Invalid or inactive company", 400);
    }

    const { data: authData, error: authError } =
      await serviceClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name, role: "provider" },
      });

    if (authError) return errorResponse(authError.message, 400);

    const userId = authData.user!.id;

    await serviceClient.from("profiles").insert({
      id: userId,
      role: "provider",
      full_name,
      phone: phone ?? null,
      company_id: resolvedCompanyId,
    });

    const { data: provider, error: providerError } = await serviceClient
      .from("providers")
      .insert({
        user_id: userId,
        company_id: resolvedCompanyId,
        skills: skills ?? [],
        experience_years: experience_years ?? 0,
        bio: bio ?? null,
        status: "approved",
        approved_at: new Date().toISOString(),
        approved_by: user.id,
      })
      .select("*, profiles(full_name, email, phone, avatar_url)")
      .single();

    if (providerError) throw new Error(providerError.message);

    return jsonResponse(
      {
        user: { id: userId, email, full_name, role: "provider" },
        provider,
      },
      201
    );
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
