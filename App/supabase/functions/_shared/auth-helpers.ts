import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

export interface AuthUserPayload {
  id: string;
  email: string;
  name: string;
  full_name: string;
  role: string;
  company_id: string | null;
  phone: string | null;
  avatar_url: string | null;
  provider_status: string | null;
  access_token?: string;
  refresh_token?: string;
  expires_in?: number;
}

export async function buildAuthUserPayload(
  serviceClient: SupabaseClient,
  userId: string,
  email: string,
  session?: { access_token: string; refresh_token: string; expires_in?: number }
): Promise<AuthUserPayload> {
  const { data: profile, error } = await serviceClient
    .from("profiles")
    .select("*")
    .eq("id", userId)
    .single();

  if (error || !profile) {
    throw new Error("Profile not found for this account");
  }

  let providerStatus: string | null = null;
  if (profile.role === "provider") {
    const { data: provider } = await serviceClient
      .from("providers")
      .select("status")
      .eq("user_id", userId)
      .maybeSingle();
    providerStatus = (provider?.status as string | undefined) ?? null;
  }

  const fullName = (profile.full_name as string | null) ?? email;

  return {
    id: userId,
    email,
    name: fullName,
    full_name: fullName,
    role: profile.role as string,
    company_id: (profile.company_id as string | null) ?? null,
    phone: (profile.phone as string | null) ?? null,
    avatar_url: (profile.avatar_url as string | null) ?? null,
    provider_status: providerStatus,
    access_token: session?.access_token,
    refresh_token: session?.refresh_token,
    expires_in: session?.expires_in,
  };
}

export function formatAuthErrorMessage(message: string): string {
  if (message.includes("Invalid login credentials")) {
    return "Email or password is incorrect.";
  }
  if (message.includes("Email not confirmed")) {
    return "Please confirm your email before signing in.";
  }
  return message;
}
