"use client";

import { useCallback, useEffect, useState } from "react";
import { invokeFunction, Button, Card, subscribeToTables, unsubscribeChannel } from "@handyman/shared";
import type { Booking, Provider } from "@handyman/shared";
import { BOOKING_STATUS_LABELS } from "@handyman/shared";

const REASSIGNABLE_STATUSES = new Set(["pending", "assigned", "rejected"]);

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [providers, setProviders] = useState<Provider[]>([]);
  const [assigning, setAssigning] = useState<string | null>(null);
  const [selectedProvider, setSelectedProvider] = useState("");

  const load = useCallback(async () => {
    const [b, p] = await Promise.all([
      invokeFunction<{ bookings: Booking[] }>("bookings-list", { method: "GET" }),
      invokeFunction<{ providers: Provider[] }>("company-providers-manage", { method: "GET" }),
    ]);
    setBookings(b.bookings);
    setProviders(p.providers.filter((pr) => pr.status === "approved"));
  }, []);

  useEffect(() => {
    load();
    const channel = subscribeToTables("company-bookings", ["bookings", "providers"], load);
    return () => unsubscribeChannel(channel);
  }, [load]);

  function openAssign(booking: Booking) {
    setAssigning(booking.id);
    setSelectedProvider(booking.provider_id ?? "");
  }

  async function assignProvider(bookingId: string) {
    if (!selectedProvider) return;
    await invokeFunction("bookings-assign", { body: { booking_id: bookingId, provider_id: selectedProvider } });
    setAssigning(null);
    setSelectedProvider("");
    load();
  }

  async function cancelBooking(bookingId: string) {
    if (!confirm("Cancel this booking?")) return;
    await invokeFunction("bookings-cancel", { body: { booking_id: bookingId } });
    load();
  }

  return (
    <div>
      <h1 className="glass-page-title mb-6">Bookings</h1>
      <div className="space-y-4">
        {bookings.map((b) => {
          const canAssign = REASSIGNABLE_STATUSES.has(b.status);
          const isReassign = b.status === "assigned" || b.status === "rejected";

          return (
            <Card key={b.id}>
              <div className="flex flex-wrap items-start justify-between gap-4">
                <div>
                  <p className="font-semibold">{b.services?.name}</p>
                  <p className="text-sm text-[var(--color-text-secondary)]">
                    Customer: {b.customers?.profiles?.full_name ?? "—"}
                  </p>
                  <p className="text-sm">Provider: {b.providers?.profiles?.full_name ?? "Unassigned"}</p>
                  <p className="text-sm">{new Date(b.scheduled_at).toLocaleString()} — {b.address}</p>
                  <span className="glass-panel mt-2 inline-block rounded-full px-2.5 py-1 text-xs font-medium text-[var(--color-primary)]">
                    {BOOKING_STATUS_LABELS[b.status]}
                  </span>
                </div>
                <div className="flex flex-wrap gap-2">
                  {canAssign && (
                    <>
                      {assigning === b.id ? (
                        <div className="flex gap-2">
                          <select className="glass-select py-1.5 text-sm" value={selectedProvider} onChange={(e) => setSelectedProvider(e.target.value)}>
                            <option value="">Select provider</option>
                            {providers.map((p) => (
                              <option key={p.id} value={p.id}>{p.profiles?.full_name}</option>
                            ))}
                          </select>
                          <Button size="sm" onClick={() => assignProvider(b.id)}>
                            {isReassign ? "Re-assign" : "Assign"}
                          </Button>
                          <Button size="sm" variant="secondary" onClick={() => { setAssigning(null); setSelectedProvider(""); }}>Cancel</Button>
                        </div>
                      ) : (
                        <Button size="sm" onClick={() => openAssign(b)}>
                          {isReassign ? "Re-assign Provider" : "Assign Provider"}
                        </Button>
                      )}
                    </>
                  )}
                  {!["completed", "cancelled"].includes(b.status) && (
                    <Button size="sm" variant="danger" onClick={() => cancelBooking(b.id)}>Cancel</Button>
                  )}
                </div>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
