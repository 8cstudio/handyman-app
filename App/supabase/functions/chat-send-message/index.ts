import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  assertBookingAllowsChat,
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
    const { chat_room_id, content, message_type = "text" } = await req.json();

    if (!chat_room_id || !content) {
      return errorResponse("chat_room_id and content are required");
    }

    const { data: room } = await serviceClient
      .from("chat_rooms")
      .select("booking_id")
      .eq("id", chat_room_id)
      .single();

    if (!room) return errorResponse("Chat room not found", 404);

    try {
      await assertBookingAllowsChat(serviceClient, room.booking_id as string);
    } catch (e) {
      return errorResponse((e as Error).message, 403);
    }

    const { data: message, error } = await serviceClient
      .from("messages")
      .insert({
        chat_room_id,
        sender_id: user.id,
        content,
        message_type,
      })
      .select("*, profiles(full_name, avatar_url)")
      .single();

    if (error) throw new Error(error.message);

    return jsonResponse({ message }, 201);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
