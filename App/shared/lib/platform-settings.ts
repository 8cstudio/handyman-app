import type { PlatformSettings } from "../types";

export async function fetchPlatformSettings(): Promise<PlatformSettings | null> {
  const response = await fetch("/api/v1/platform-settings", {
    credentials: "include",
    cache: "no-store",
  });

  if (!response.ok) return null;

  const data = (await response.json()) as { settings?: PlatformSettings };
  return data.settings ?? null;
}

export const PLATFORM_SETTINGS_UPDATED_EVENT = "platform-settings-updated";

export function notifyPlatformSettingsUpdated() {
  if (typeof window !== "undefined") {
    window.dispatchEvent(new CustomEvent(PLATFORM_SETTINGS_UPDATED_EVENT));
  }
}
