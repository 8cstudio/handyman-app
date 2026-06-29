import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
  requireRole,
} from "../_shared/utils.ts";

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const roleCheck = await requireRole(auth.client, user.id, ["customer"]);
  if (roleCheck instanceof Response) return roleCheck;

  const serviceClient = getServiceClient();

  try {
    const { booking_id, rating, comment } = await req.json();

    if (!booking_id || !rating) {
      return errorResponse("booking_id and rating (1-5) are required");
    }

    if (rating < 1 || rating > 5) {
      return errorResponse("rating must be between 1 and 5");
    }

    const { data: customer } = await serviceClient
      .from("customers")
      .select("id")
      .eq("user_id", user.id)
      .single();

    if (!customer) return errorResponse("Customer profile not found", 404);

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("status, provider_id, customer_id")
      .eq("id", booking_id)
      .single();

    if (!booking) return errorResponse("Booking not found", 404);
    if (booking.status !== "completed") {
      return errorResponse("Can only review completed bookings", 400);
    }
    if (booking.customer_id !== customer.id) {
      return errorResponse("Forbidden", 403);
    }
    if (!booking.provider_id) {
      return errorResponse("No provider assigned to this booking", 400);
    }

    const { data: existing } = await serviceClient
      .from("reviews")
      .select("id")
      .eq("booking_id", booking_id)
      .maybeSingle();

    if (existing) return errorResponse("Review already submitted", 400);

    const { data: review, error } = await serviceClient
      .from("reviews")
      .insert({
        booking_id,
        customer_id: customer.id,
        provider_id: booking.provider_id,
        rating,
        comment: comment ?? null,
      })
      .select("*")
      .single();

    if (error) throw new Error(error.message);

    return jsonResponse({ review }, 201);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
