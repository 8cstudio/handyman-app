import { GoogleAuth } from "google-auth-library";
import type { SupabaseClient } from "@supabase/supabase-js";

const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

export type PushData = {
  type: "chat" | "booking_status";
  booking_id: string;
  status?: string;
};

type PushNotificationInput = {
  title: string;
  body: string;
  data: PushData;
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

let cachedAuth: GoogleAuth | null = null;
let cachedProjectId: string | null = null;

function getServiceAccount(): ServiceAccount | null {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (!raw) return null;

  try {
    return JSON.parse(raw) as ServiceAccount;
  } catch {
    console.error("[push] FIREBASE_SERVICE_ACCOUNT_JSON is invalid JSON");
    return null;
  }
}

function getGoogleAuth(): GoogleAuth | null {
  if (cachedAuth) return cachedAuth;

  const credentials = getServiceAccount();
  if (!credentials) return null;

  cachedProjectId = credentials.project_id;
  cachedAuth = new GoogleAuth({
    credentials,
    scopes: [FCM_SCOPE],
  });
  return cachedAuth;
}

async function getAccessToken(): Promise<string | null> {
  const auth = getGoogleAuth();
  if (!auth) return null;

  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();
  return tokenResponse.token ?? null;
}

async function fetchDeviceTokens(
  serviceClient: SupabaseClient,
  userIds: string[]
): Promise<string[]> {
  const uniqueIds = [...new Set(userIds.filter(Boolean))];
  if (!uniqueIds.length) return [];

  const { data, error } = await serviceClient
    .from("device_tokens")
    .select("token")
    .in("user_id", uniqueIds);

  if (error) {
    console.error("[push] Failed to load device tokens:", error.message);
    return [];
  }

  return [...new Set((data ?? []).map((row) => row.token as string).filter(Boolean))];
}

async function sendFcmToToken(
  token: string,
  notification: PushNotificationInput
): Promise<void> {
  const projectId = cachedProjectId ?? getServiceAccount()?.project_id;
  const accessToken = await getAccessToken();

  if (!projectId || !accessToken) {
    console.warn("[push] Skipped send — FIREBASE_SERVICE_ACCOUNT_JSON not configured");
    return;
  }

  const data: Record<string, string> = {
    type: notification.data.type,
    booking_id: notification.data.booking_id,
  };
  if (notification.data.status) {
    data.status = notification.data.status;
  }

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data,
          android: {
            priority: "HIGH",
            notification: {
              channel_id: "handyman_default",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
              },
            },
          },
        },
      }),
    }
  );

  if (!response.ok) {
    const detail = await response.text();
    console.error(`[push] FCM error (${response.status}): ${detail}`);
  }
}

export function formatBookingStatus(status: string): string {
  const labels: Record<string, string> = {
    pending: "Pending",
    assigned: "Assigned",
    accepted: "Accepted",
    rejected: "Rejected",
    in_progress: "In Progress",
    completed: "Completed",
    cancelled: "Cancelled",
  };
  return labels[status] ?? status.replace(/_/g, " ");
}

export async function sendPushToUsers(
  serviceClient: SupabaseClient,
  userIds: Array<string | null | undefined>,
  notification: PushNotificationInput
): Promise<void> {
  const tokens = await fetchDeviceTokens(serviceClient, userIds as string[]);
  if (!tokens.length) return;

  await Promise.allSettled(
    tokens.map((token) => sendFcmToToken(token, notification))
  );
}

export function notifyUsersAsync(
  serviceClient: SupabaseClient,
  userIds: Array<string | null | undefined>,
  notification: PushNotificationInput
): void {
  void sendPushToUsers(serviceClient, userIds, notification).catch((error) => {
    console.error("[push] notifyUsersAsync failed:", (error as Error).message);
  });
}

export async function getBookingParticipantUserIds(
  serviceClient: SupabaseClient,
  bookingId: string
): Promise<{ customerUserId: string | null; providerUserId: string | null }> {
  const { data: booking } = await serviceClient
    .from("bookings")
    .select("customers(user_id), providers(user_id)")
    .eq("id", bookingId)
    .single();

  const customerUserId =
    (booking?.customers as { user_id?: string } | null)?.user_id ?? null;
  const providerUserId =
    (booking?.providers as { user_id?: string } | null)?.user_id ?? null;

  return { customerUserId, providerUserId };
}
