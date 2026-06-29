"use client";

import { useCallback, useEffect, useState } from "react";
import { invokeFunction, Card, ErrorAlert } from "@handyman/shared";

interface CustomerRow {
  id: string;
  default_address?: string;
  profiles: { full_name: string; email?: string | null; phone?: string };
}

export default function CustomersPage() {
  const [customers, setCustomers] = useState<CustomerRow[]>([]);
  const [selected, setSelected] = useState<CustomerRow | null>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const data = await invokeFunction<{ customers: CustomerRow[] }>(
        "company-customers-list",
        { method: "GET" }
      );
      setCustomers(data.customers);
    } catch (err) {
      setError((err as Error).message);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  return (
    <div>
      <h1 className="glass-page-title mb-2">Customers</h1>
      <p className="mb-6 text-sm text-[var(--color-text-secondary)]">
        Only customers who have booked a service with your company are shown here.
      </p>

      {error && (
        <div className="mb-4">
          <ErrorAlert message={error} onDismiss={() => setError("")} />
        </div>
      )}

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="glass-table-wrap lg:col-span-2 overflow-x-auto">
          {loading ? (
            <p className="p-4 text-sm text-[var(--color-text-secondary)]">Loading...</p>
          ) : customers.length === 0 ? (
            <p className="p-4 text-sm text-[var(--color-text-secondary)]">
              No customers yet. They will appear after their first booking with your company.
            </p>
          ) : (
            <table className="w-full text-left text-sm">
              <thead>
                <tr>
                  <th className="px-4 py-3">Name</th>
                  <th className="px-4 py-3">Email</th>
                  <th className="px-4 py-3">Phone</th>
                  <th className="px-4 py-3">Address</th>
                </tr>
              </thead>
              <tbody>
                {customers.map((c) => (
                  <tr
                    key={c.id}
                    className="cursor-pointer border-t transition-colors hover:bg-[var(--glass-bg)]"
                    onClick={() => setSelected(c)}
                  >
                    <td className="px-4 py-3 font-medium">{c.profiles?.full_name}</td>
                    <td className="px-4 py-3">{c.profiles?.email ?? "—"}</td>
                    <td className="px-4 py-3">{c.profiles?.phone ?? "—"}</td>
                    <td className="px-4 py-3">{c.default_address ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
        {selected && (
          <Card title="Customer Details">
            <p><strong>Name:</strong> {selected.profiles?.full_name}</p>
            <p><strong>Email:</strong> {selected.profiles?.email ?? "—"}</p>
            <p><strong>Phone:</strong> {selected.profiles?.phone ?? "—"}</p>
            <p><strong>Address:</strong> {selected.default_address ?? "—"}</p>
          </Card>
        )}
      </div>
    </div>
  );
}
