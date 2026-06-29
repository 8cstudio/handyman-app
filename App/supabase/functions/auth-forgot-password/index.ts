import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
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

    if (!email) {
      return errorResponse("Email is required", 400);
    }

    const redirectTo =
      typeof body.redirect_to === "string" && body.redirect_to.length > 0
        ? body.redirect_to
        : "handyman://reset-password";

    const serviceClient = getServiceClient();
    const { error } = await serviceClient.auth.resetPasswordForEmail(email, {
      redirectTo,
    });

    if (error) {
      return errorResponse(error.message, 400);
    }

    return jsonResponse({
      message:
        "If an account exists for this email, password reset instructions have been sent.",
    });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
