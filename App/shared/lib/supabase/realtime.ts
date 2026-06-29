import { createClient } from "./client";
import type { RealtimeChannel } from "@supabase/supabase-js";

/**
 * Subscribe to INSERT/UPDATE/DELETE on one or more public tables.
 * Returns the channel — call supabase.removeChannel(channel) on cleanup.
 */
export function subscribeToTables(
  channelName: string,
  tables: string[],
  onChange: () => void
): RealtimeChannel {
  const supabase = createClient();
  let channel = supabase.channel(channelName);

  for (const table of tables) {
    channel = channel.on(
      "postgres_changes",
      { event: "*", schema: "public", table },
      onChange
    );
  }

  channel.subscribe();
  return channel;
}

export function unsubscribeChannel(channel: RealtimeChannel | null) {
  if (!channel) return;
  const supabase = createClient();
  supabase.removeChannel(channel);
}
