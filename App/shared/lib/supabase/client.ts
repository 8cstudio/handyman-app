import { createBrowserClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";
import { formatApiError } from "../errors/format-error";
import { logClientError } from "../errors/client-logger";

let client: SupabaseClient | null = null;

export function createClient() {
  if (client) return client;

  client = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  return client;
}

export async function invokeFunction<T>(
  name: string,
  options?: { method?: string; body?: unknown }
): Promise<T> {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();

  const method = options?.method ?? "POST";
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  if (session?.access_token) {
    headers.Authorization = `Bearer ${session.access_token}`;
  }

  const response = await fetch(`/api/v1/${name}`, {
    method,
    credentials: "include",
    headers,
    body: method !== "GET" && options?.body !== undefined
      ? JSON.stringify(options.body)
      : undefined,
  });

  let data: unknown = null;
  try {
    data = await response.json();
  } catch {
    data = null;
  }

  if (!response.ok) {
    const detail =
      data && typeof data === "object" && "error" in data
        ? String((data as { error: unknown }).error)
        : response.statusText;
    const message = formatApiError(detail);
    logClientError(`api/${name}`, detail, { method });
    throw new Error(message);
  }

  if (data && typeof data === "object" && "error" in data) {
    const bodyError = String((data as { error: unknown }).error);
    const message = formatApiError(bodyError);
    logClientError(`api/${name}`, bodyError, { method });
    throw new Error(message);
  }

  return data as T;
}
