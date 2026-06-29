import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
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

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const serviceClient = getServiceClient();

  try {
    const { chat_room_id, message_ids } = await req.json();

    if (!chat_room_id) return errorResponse("chat_room_id is required");

    let query = serviceClient
      .from("messages")
      .update({ read_at: new Date().toISOString() })
      .eq("chat_room_id", chat_room_id)
      .neq("sender_id", user.id)
      .is("read_at", null);

    if (message_ids?.length) {
      query = query.in("id", message_ids);
    }

    const { error } = await query;
    if (error) throw new Error(error.message);

    return jsonResponse({ success: true });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
