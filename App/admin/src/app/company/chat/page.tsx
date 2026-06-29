"use client";

import { useCallback, useEffect, useState } from "react";
import { createClient, Card, getMyCompanyId, subscribeToTables, unsubscribeChannel } from "@handyman/shared";
import type { Message } from "@handyman/shared";

interface ChatRoom {
  id: string;
  booking_id: string;
  bookings: {
    services: { name: string };
    customers: { profiles: { full_name: string } };
    providers: { profiles: { full_name: string } };
  };
}

export default function ChatPage() {
  const [rooms, setRooms] = useState<ChatRoom[]>([]);
  const [selectedRoom, setSelectedRoom] = useState<string | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);

  const loadRooms = useCallback(async () => {
    const supabase = createClient();
    const companyId = await getMyCompanyId(supabase);
    if (!companyId) return;

    const { data } = await supabase
      .from("chat_rooms")
      .select(`
        id, booking_id,
        bookings(services(name), customers(profiles(full_name)), providers(profiles!providers_user_id_fkey(full_name)), company_id)
      `);

    const filtered = (data as ChatRoom[])?.filter(
      (r) => (r.bookings as unknown as { company_id: string }).company_id === companyId
    ) ?? [];
    setRooms(filtered);
  }, []);

  useEffect(() => {
    loadRooms();
    const channel = subscribeToTables("company-chat-rooms", ["chat_rooms", "bookings"], loadRooms);
    return () => unsubscribeChannel(channel);
  }, [loadRooms]);

  useEffect(() => {
    if (!selectedRoom) return;
    async function loadMessages() {
      const supabase = createClient();
      const { data } = await supabase
        .from("messages")
        .select("*, profiles(full_name)")
        .eq("chat_room_id", selectedRoom)
        .order("created_at");
      setMessages((data as Message[]) ?? []);
    }
    loadMessages();

    const supabase = createClient();
    const channel = supabase
      .channel(`chat-${selectedRoom}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "messages", filter: `chat_room_id=eq.${selectedRoom}` },
        () => loadMessages()
      )
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [selectedRoom]);

  return (
    <div>
      <h1 className="glass-page-title mb-6">Chat Oversight</h1>
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <div className="space-y-2">
          {rooms.map((room) => (
            <button
              key={room.id}
              onClick={() => setSelectedRoom(room.id)}
              className={`w-full rounded-lg border p-3 text-left text-sm ${
                selectedRoom === room.id ? "border-[var(--color-primary)] bg-blue-50" : ""
              }`}
            >
              <p className="font-medium">{room.bookings?.services?.name}</p>
              <p className="text-xs text-[var(--color-text-secondary)]">
                {room.bookings?.customers?.profiles?.full_name} ↔ {room.bookings?.providers?.profiles?.full_name}
              </p>
            </button>
          ))}
        </div>
        <Card className="lg:col-span-2" title="Messages (Read Only)">
          {selectedRoom ? (
            <div className="max-h-96 space-y-2 overflow-y-auto">
              {messages.map((m) => (
                <div key={m.id} className="glass-panel rounded-xl p-2 text-sm">
                  <p className="font-medium">{m.profiles?.full_name}</p>
                  <p>{m.content}</p>
                  <p className="text-xs text-gray-400">{new Date(m.created_at).toLocaleString()}</p>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-[var(--color-text-secondary)]">Select a chat room</p>
          )}
        </Card>
      </div>
    </div>
  );
}
