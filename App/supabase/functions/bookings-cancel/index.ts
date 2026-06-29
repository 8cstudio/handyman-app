import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
  logBookingStatus,
  requireRole,
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
    const { booking_id, reason } = await req.json();
    if (!booking_id) return errorResponse("booking_id is required");

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("*, customers(user_id)")
      .eq("id", booking_id)
      .single();

    if (!booking) return errorResponse("Booking not found", 404);

    const profile = await serviceClient.from("profiles").select("role").eq("id", user.id).single();
    const role = profile.data?.role;

    const canCancel =
      role === "company_admin" ||
      role === "super_admin" ||
      (role === "customer" && booking.customers?.user_id === user.id);

    if (!canCancel) return errorResponse("Forbidden", 403);
    if (["completed", "cancelled"].includes(booking.status)) {
      return errorResponse("Booking cannot be cancelled", 400);
    }

    const oldStatus = booking.status;

    const { data: updated, error } = await serviceClient
      .from("bookings")
      .update({ status: "cancelled" })
      .eq("id", booking_id)
      .select("*")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(serviceClient, booking_id, oldStatus, "cancelled", user.id, reason);

    return jsonResponse({ booking: updated });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
