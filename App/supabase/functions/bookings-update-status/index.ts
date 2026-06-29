import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  ensureChatRoom,
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
  logBookingStatus,
  requireRole,
} from "../_shared/utils.ts";

const PROVIDER_TRANSITIONS: Record<string, string[]> = {
  assigned: ["accepted", "rejected"],
  accepted: ["in_progress"],
  in_progress: ["completed"],
};

const ADMIN_TRANSITIONS: Record<string, string[]> = {
  pending: ["cancelled"],
  assigned: ["cancelled"],
  accepted: ["cancelled"],
  in_progress: ["cancelled"],
};

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const serviceClient = getServiceClient();

  try {
    const { booking_id, status, note } = await req.json();

    if (!booking_id || !status) {
      return errorResponse("booking_id and status are required");
    }

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("*, providers(user_id)")
      .eq("id", booking_id)
      .single();

    if (!booking) return errorResponse("Booking not found", 404);

    const profile = await serviceClient.from("profiles").select("role").eq("id", user.id).single();
    const role = profile.data?.role;

    let allowed = false;
    if (role === "provider" && booking.providers?.user_id === user.id) {
      allowed = PROVIDER_TRANSITIONS[booking.status]?.includes(status) ?? false;
    } else if (role === "company_admin" || role === "super_admin") {
      allowed = ADMIN_TRANSITIONS[booking.status]?.includes(status) ?? false;
      if (["assigned", "accepted", "in_progress", "completed"].includes(status)) {
        allowed = true;
      }
    }

    if (!allowed) return errorResponse(`Cannot transition from ${booking.status} to ${status}`, 403);

    const oldStatus = booking.status;

    const { data: updated, error } = await serviceClient
      .from("bookings")
      .update({ status })
      .eq("id", booking_id)
      .select("*")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(serviceClient, booking_id, oldStatus, status, user.id, note);

    if (status === "accepted") {
      await ensureChatRoom(serviceClient, booking_id);
    }

    return jsonResponse({ booking: updated });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
