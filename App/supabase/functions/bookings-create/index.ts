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

  const roleCheck = await requireRole(auth.client, user.id, ["customer"]);
  if (roleCheck instanceof Response) return roleCheck;

  const serviceClient = getServiceClient();

  try {
    const body = await req.json();
    const { service_id, scheduled_at, address, notes } = body;

    if (!service_id || !scheduled_at || !address) {
      return errorResponse("service_id, scheduled_at, and address are required");
    }

    const { data: customer } = await serviceClient
      .from("customers")
      .select("id")
      .eq("user_id", user.id)
      .single();

    if (!customer) return errorResponse("Customer profile not found", 404);

    const { data: service } = await serviceClient
      .from("services")
      .select("company_id")
      .eq("id", service_id)
      .single();

    if (!service) return errorResponse("Service not found", 404);

    const { data: booking, error } = await serviceClient
      .from("bookings")
      .insert({
        company_id: service.company_id,
        service_id,
        customer_id: customer.id,
        scheduled_at,
        address,
        notes,
        status: "pending",
      })
      .select("*, services(name, price), customers(profiles(full_name))")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(serviceClient, booking.id, null, "pending", user.id, "Booking created");

    return jsonResponse({ booking }, 201);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
