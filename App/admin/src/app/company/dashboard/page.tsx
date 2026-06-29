"use client";

import { useCallback, useEffect, useState } from "react";
import {
  invokeFunction,
  Card,
  ErrorAlert,
  subscribeToTables,
  unsubscribeChannel,
} from "@handyman/shared";

interface DashboardStats {
  bookings: number;
  providers: number;
  services: number;
  pending: number;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    bookings: 0,
    providers: 0,
    services: 0,
    pending: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    setError("");
    try {
      const data = await invokeFunction<{ stats: DashboardStats }>(
        "company-dashboard-stats",
        { method: "GET" }
      );
      setStats(data.stats);
    } catch (err) {
      setError((err as Error).message);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
    const channel = subscribeToTables(
      "company-dashboard",
      ["bookings", "providers", "services", "categories"],
      load
    );
    return () => unsubscribeChannel(channel);
  }, [load]);

  const cards = [
    { label: "Total Bookings", value: stats.bookings },
    { label: "Active Providers", value: stats.providers },
    { label: "Active Services", value: stats.services },
    { label: "Pending Bookings", value: stats.pending },
  ];

  return (
    <div>
      <h1 className="glass-page-title mb-6">Dashboard</h1>
      {error && (
        <div className="mb-4">
          <ErrorAlert message={error} onDismiss={() => setError("")} />
        </div>
      )}
      {loading ? (
        <p className="text-[var(--color-text-secondary)]">Loading...</p>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {cards.map((c) => (
            <Card key={c.label}>
              <p className="text-sm text-[var(--color-text-secondary)]">{c.label}</p>
              <p className="glass-stat-value mt-1">{c.value}</p>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
