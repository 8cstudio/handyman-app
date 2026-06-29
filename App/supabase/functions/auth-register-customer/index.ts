import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  corsHeaders,
  errorResponse,
  getServiceClient,
  handleCors,
  jsonResponse,
} from "../_shared/utils.ts";

interface RegisterCustomerBody {
  email: string;
  password: string;
  full_name: string;
  phone?: string;
  company_id?: string;
}

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  try {
    const body: RegisterCustomerBody = await req.json();
    const { email, password, full_name, phone, company_id } = body;

    if (!email || !password || !full_name) {
      return errorResponse("email, password, and full_name are required");
    }

    const serviceClient = getServiceClient();

    const { data: authData, error: authError } = await serviceClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name, role: "customer" },
    });

    if (authError) return errorResponse(authError.message, 400);

    const userId = authData.user!.id;

    await serviceClient.from("profiles").insert({
      id: userId,
      role: "customer",
      full_name,
      phone: phone ?? null,
      company_id: company_id ?? "a0000000-0000-4000-8000-000000000001",
    });

    await serviceClient.from("customers").insert({
      user_id: userId,
    });

    return jsonResponse({
      user: { id: userId, email, full_name, role: "customer" },
    }, 201);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
