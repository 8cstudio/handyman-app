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

  const roleCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
  if (roleCheck instanceof Response) return roleCheck;

  const serviceClient = getServiceClient();

  try {
    const { booking_id, provider_id } = await req.json();

    if (!booking_id || !provider_id) {
      return errorResponse("booking_id and provider_id are required");
    }

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("status")
      .eq("id", booking_id)
      .single();

    if (!booking) return errorResponse("Booking not found", 404);

    const oldStatus = booking.status;

    const { data: updated, error } = await serviceClient
      .from("bookings")
      .update({ provider_id, status: "assigned" })
      .eq("id", booking_id)
      .select("*, services(name), providers(profiles(full_name))")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(serviceClient, booking_id, oldStatus, "assigned", user.id, "Provider assigned");

    return jsonResponse({ booking: updated });
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
