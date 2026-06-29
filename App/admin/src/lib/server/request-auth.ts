import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { NextRequest } from "next/server";
import type { SupabaseClient, User } from "@supabase/supabase-js";
import { getUserClient } from "./supabase-admin";
import { getServiceClient } from "./supabase-admin";

export type AuthContext = {
  user: User;
  client: SupabaseClient;
};

export async function getAuthFromRequest(
  request: NextRequest
): Promise<AuthContext | null> {
  const authHeader = request.headers.get("Authorization");

  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.replace(/^Bearer\s+/i, "");
    const client = getUserClient(authHeader);
    const { data, error } = await client.auth.getUser(token);
    if (!error && data.user) {
      return { user: data.user, client };
    }

    const userResponse = await fetch(
      `${process.env.NEXT_PUBLIC_SUPABASE_URL}/auth/v1/user`,
      {
        headers: {
          Authorization: authHeader,
          apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        },
      }
    );

    if (userResponse.ok) {
      const user = (await userResponse.json()) as User;
      return { user, client };
    }
  }

  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll() {
          // Route handlers do not mutate auth cookies here.
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (user) {
    return { user, client: supabase };
  }

  return null;
}

export async function getProfile(client: SupabaseClient, userId: string) {
  const { data, error } = await client.from("profiles").select("*").eq("id", userId).single();
  if (error) throw new Error(error.message);
  return data;
}

export async function requireRole(
  client: SupabaseClient,
  userId: string,
  roles: string[]
) {
  const profile = await getProfile(client, userId);
  if (!roles.includes(profile.role as string)) {
    throw new Error("Forbidden");
  }
  return { profile };
}

export async function logBookingStatus(
  bookingId: string,
  oldStatus: string | null,
  newStatus: string,
  changedBy: string,
  note?: string
) {
  const serviceClient = getServiceClient();
  await serviceClient.from("booking_status_history").insert({
    booking_id: bookingId,
    old_status: oldStatus,
    new_status: newStatus,
    changed_by: changedBy,
    note,
  });
}

export async function ensureChatRoom(bookingId: string) {
  const serviceClient = getServiceClient();
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
  return data.id as string;
}
