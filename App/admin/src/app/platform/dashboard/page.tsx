"use client";

import { useCallback, useEffect, useState } from "react";
import { createClient, Card, subscribeToTables, unsubscribeChannel } from "@handyman/shared";

interface Stats {
  companies: number;
  bookings: number;
  providers: number;
  customers: number;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats>({ companies: 0, bookings: 0, providers: 0, customers: 0 });
  const [loading, setLoading] = useState(true);

  const loadStats = useCallback(async () => {
    const supabase = createClient();
    const [companies, bookings, providers, customers] = await Promise.all([
      supabase.from("companies").select("id", { count: "exact", head: true }),
      supabase.from("bookings").select("id", { count: "exact", head: true }),
      supabase.from("providers").select("id", { count: "exact", head: true }).eq("status", "approved"),
      supabase.from("customers").select("id", { count: "exact", head: true }),
    ]);

    setStats({
      companies: companies.count ?? 0,
      bookings: bookings.count ?? 0,
      providers: providers.count ?? 0,
      customers: customers.count ?? 0,
    });
    setLoading(false);
  }, []);

  useEffect(() => {
    loadStats();
    const channel = subscribeToTables(
      "super-admin-dashboard",
      ["companies", "bookings", "providers", "customers"],
      loadStats
    );
    return () => unsubscribeChannel(channel);
  }, [loadStats]);

  const cards = [
    { label: "Companies", value: stats.companies },
    { label: "Total Bookings", value: stats.bookings },
    { label: "Active Providers", value: stats.providers },
    { label: "Customers", value: stats.customers },
  ];

  return (
    <div>
      <h1 className="glass-page-title mb-6 text-[var(--color-text)]">Dashboard</h1>
      {loading ? (
        <p className="text-[var(--color-text-secondary)]">Loading...</p>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {cards.map((card) => (
            <Card key={card.label}>
              <p className="text-sm text-[var(--color-text-secondary)]">{card.label}</p>
              <p className="glass-stat-value mt-1">{card.value}</p>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
