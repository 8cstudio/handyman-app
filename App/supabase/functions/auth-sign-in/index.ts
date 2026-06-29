import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  buildAuthUserPayload,
  formatAuthErrorMessage,
} from "../_shared/auth-helpers.ts";
import {
  errorResponse,
  getServiceClient,
  handleCors,
  jsonResponse,
} from "../_shared/utils.ts";

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  try {
    const body = await req.json();
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";

    if (!email || !password) {
      return errorResponse("Email and password are required", 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

    const tokenResponse = await fetch(
      `${supabaseUrl}/auth/v1/token?grant_type=password`,
      {
        method: "POST",
        headers: {
          apikey: supabaseAnonKey,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      }
    );

    const tokenData = await tokenResponse.json();

    if (!tokenResponse.ok) {
      const message = formatAuthErrorMessage(
        (tokenData.error_description as string | undefined) ??
          (tokenData.msg as string | undefined) ??
          (tokenData.error as string | undefined) ??
          "Sign in failed"
      );
      return errorResponse(message, 401);
    }

    const allowedRoles = ["customer", "provider"];
    const serviceClient = getServiceClient();
    const userPayload = await buildAuthUserPayload(
      serviceClient,
      tokenData.user.id as string,
      email,
      {
        access_token: tokenData.access_token as string,
        refresh_token: tokenData.refresh_token as string,
        expires_in: tokenData.expires_in as number | undefined,
      }
    );

    if (!allowedRoles.includes(userPayload.role)) {
      return errorResponse(
        "This account cannot sign in through the mobile app.",
        403
      );
    }

    return jsonResponse({ user: userPayload });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
