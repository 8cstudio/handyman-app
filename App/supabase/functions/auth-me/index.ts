import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { buildAuthUserPayload } from "../_shared/auth-helpers.ts";
import {
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
} from "../_shared/utils.ts";

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "GET" && req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  try {
    const serviceClient = getServiceClient();
    const userPayload = await buildAuthUserPayload(
      serviceClient,
      user.id,
      user.email ?? ""
    );

    return jsonResponse({ user: userPayload });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
