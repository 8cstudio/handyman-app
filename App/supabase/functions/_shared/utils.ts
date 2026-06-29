import { createClient, SupabaseClient, User } from "https://esm.sh/@supabase/supabase-js@2.49.4";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

export function handleCors(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  return null;
}

export function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ error: message }, status);
}

export function getServiceClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );
}

export function getUserClient(authHeader: string): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } }
  );
}

export async function getAuthUser(req: Request): Promise<{ user: User; client: SupabaseClient } | Response> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return errorResponse("Missing authorization header", 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");

  const client = getUserClient(authHeader);

  // Prefer auth.getUser(jwt) on newer tokens (ES256 publishable-key auth).
  const { data: jwtUserData, error: jwtUserError } = await client.auth.getUser(token);
  if (!jwtUserError && jwtUserData.user) {
    return { user: jwtUserData.user, client };
  }

  // Fallback: validate via Auth REST API (works with all key types).
  const userResponse = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: {
      Authorization: authHeader,
      apikey: supabaseAnonKey,
    },
  });

  if (!userResponse.ok) {
    return errorResponse("Unauthorized", 401);
  }

  const user = (await userResponse.json()) as User;
  return { user, client };
}

export async function getProfile(client: SupabaseClient, userId: string) {
  const { data, error } = await client
    .from("profiles")
    .select("*")
    .eq("id", userId)
    .single();
  if (error) throw new Error(error.message);
  return data;
}

export async function requireRole(
  client: SupabaseClient,
  userId: string,
  roles: string[]
): Promise<{ profile: Record<string, unknown> } | Response> {
  const profile = await getProfile(client, userId);
  if (!roles.includes(profile.role as string)) {
    return errorResponse("Forbidden", 403);
  }
  return { profile };
}

export const CHAT_ALLOWED_BOOKING_STATUSES = new Set([
  "accepted",
  "in_progress",
  "completed",
]);

export async function assertBookingAllowsChat(
  serviceClient: SupabaseClient,
  bookingId: string
) {
  const { data: booking } = await serviceClient
    .from("bookings")
    .select("status")
    .eq("id", bookingId)
    .single();

  if (!booking || !CHAT_ALLOWED_BOOKING_STATUSES.has(booking.status as string)) {
    throw new Error("Chat is available after the provider accepts the order");
  }
}

export async function logBookingStatus(
  serviceClient: SupabaseClient,
  bookingId: string,
  oldStatus: string | null,
  newStatus: string,
  changedBy: string,
  note?: string
) {
  await serviceClient.from("booking_status_history").insert({
    booking_id: bookingId,
    old_status: oldStatus,
    new_status: newStatus,
    changed_by: changedBy,
    note,
  });
}

export async function ensureChatRoom(
  serviceClient: SupabaseClient,
  bookingId: string
) {
  const { data: existing } = await serviceClient
    .from("chat_rooms")
    .select("id")
    .eq("booking_id", bookingId)
    .maybeSingle();

  if (existing) return existing.id;

  const { data, error } = await serviceClient
    .from("chat_rooms")
    .insert({ booking_id: bookingId })
    .select("id")
    .single();

  if (error) throw new Error(error.message);
  return data.id;
}
