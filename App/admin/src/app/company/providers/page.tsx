"use client";

import { useCallback, useEffect, useState } from "react";
import { invokeFunction, Button, Input, Card, ErrorAlert, subscribeToTables, unsubscribeChannel } from "@handyman/shared";
import type { Provider } from "@handyman/shared";
import { PROVIDER_STATUS_LABELS } from "@handyman/shared";

const emptyForm = {
  email: "",
  password: "",
  full_name: "",
  phone: "",
  skills: "",
  experience_years: "0",
};

const emptyEditForm = {
  full_name: "",
  phone: "",
  skills: "",
  experience_years: "0",
  bio: "",
};

export default function ProvidersPage() {
  const [providers, setProviders] = useState<Provider[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [editProvider, setEditProvider] = useState<Provider | null>(null);
  const [editForm, setEditForm] = useState(emptyEditForm);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [saving, setSaving] = useState(false);
  const [savingEdit, setSavingEdit] = useState(false);

  const load = useCallback(async () => {
    const data = await invokeFunction<{ providers: Provider[] }>("company-providers-manage", { method: "GET" });
    setProviders(data.providers);
  }, []);

  useEffect(() => {
    load().catch((err: Error) => setError(err.message));
    const channel = subscribeToTables("company-providers", ["providers"], load);
    return () => unsubscribeChannel(channel);
  }, [load]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");
    setMessage("");
    try {
      await invokeFunction("auth-register-provider", {
        body: {
          email: form.email,
          password: form.password,
          full_name: form.full_name,
          phone: form.phone || undefined,
          skills: form.skills
            .split(",")
            .map((s) => s.trim())
            .filter(Boolean),
          experience_years: Number(form.experience_years) || 0,
        },
      });
      setForm(emptyForm);
      setShowForm(false);
      setMessage("Provider account created. They can sign in on the mobile app.");
      load();
    } catch (err) {
      setError((err as Error).message);
    }
    setSaving(false);
  }

  async function handleAction(id: string, action: string) {
    setError("");
    try {
      await invokeFunction("company-providers-manage", { method: "PUT", body: { id, action } });
      load();
    } catch (err) {
      setError((err as Error).message);
    }
  }

  async function handleDelete(provider: Provider) {
    const name = provider.profiles?.full_name ?? "this provider";
    const confirmed = window.confirm(
      `Permanently delete ${name}?\n\nTheir login and profile will be removed. Bookings assigned to them will be unassigned. This cannot be undone.`
    );
    if (!confirmed) return;

    setError("");
    setMessage("");
    try {
      await invokeFunction("company-providers-manage", {
        method: "DELETE",
        body: { id: provider.id },
      });
      setMessage(`Provider "${name}" deleted.`);
      if (editProvider?.id === provider.id) setEditProvider(null);
      load();
    } catch (err) {
      setError((err as Error).message);
    }
  }

  function startEdit(provider: Provider) {
    setEditProvider(provider);
    setEditForm({
      full_name: provider.profiles?.full_name ?? "",
      phone: provider.profiles?.phone ?? "",
      skills: provider.skills?.join(", ") ?? "",
      experience_years: String(provider.experience_years ?? 0),
      bio: provider.bio ?? "",
    });
    setError("");
    setMessage("");
  }

  async function handleEditSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!editProvider) return;

    setSavingEdit(true);
    setError("");
    setMessage("");
    try {
      await invokeFunction("company-providers-manage", {
        method: "PUT",
        body: {
          id: editProvider.id,
          action: "update_profile",
          full_name: editForm.full_name,
          phone: editForm.phone,
          bio: editForm.bio,
          skills: editForm.skills
            .split(",")
            .map((s) => s.trim())
            .filter(Boolean),
          experience_years: Number(editForm.experience_years) || 0,
        },
      });
      setEditProvider(null);
      setMessage("Provider profile updated.");
      load();
    } catch (err) {
      setError((err as Error).message);
    }
    setSavingEdit(false);
  }

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="glass-page-title">Providers</h1>
          <p className="text-sm text-[var(--color-text-secondary)]">
            Create and manage provider profiles. Providers view their profile read-only in the mobile app.
          </p>
        </div>
        <Button onClick={() => setShowForm((v) => !v)}>
          {showForm ? "Cancel" : "Add Provider"}
        </Button>
      </div>

      {error && (
        <div className="mb-4">
          <ErrorAlert message={error} onDismiss={() => setError("")} />
        </div>
      )}
      {message && <p className="mb-4 text-sm text-green-600">{message}</p>}

      {showForm && (
        <Card title="New Provider Account" className="mb-6">
          <form onSubmit={handleCreate} className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Input label="Full name" value={form.full_name} onChange={(e) => setForm({ ...form, full_name: e.target.value })} required />
            <Input label="Email" type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required />
            <Input label="Temporary password" type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required />
            <Input label="Phone" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
            <Input label="Skills (comma separated)" value={form.skills} onChange={(e) => setForm({ ...form, skills: e.target.value })} className="md:col-span-2" />
            <Input label="Experience (years)" type="number" value={form.experience_years} onChange={(e) => setForm({ ...form, experience_years: e.target.value })} />
            <div className="md:col-span-2">
              <Button type="submit" disabled={saving}>{saving ? "Creating..." : "Create Provider"}</Button>
            </div>
          </form>
        </Card>
      )}

      {editProvider && (
        <Card title={`Edit Provider — ${editProvider.profiles?.full_name ?? "Provider"}`} className="mb-6">
          <form onSubmit={handleEditSubmit} className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Input label="Full name" value={editForm.full_name} onChange={(e) => setEditForm({ ...editForm, full_name: e.target.value })} required />
            <Input label="Phone" value={editForm.phone} onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })} />
            <Input label="Skills (comma separated)" value={editForm.skills} onChange={(e) => setEditForm({ ...editForm, skills: e.target.value })} className="md:col-span-2" />
            <Input label="Experience (years)" type="number" value={editForm.experience_years} onChange={(e) => setEditForm({ ...editForm, experience_years: e.target.value })} />
            <Input label="Bio" value={editForm.bio} onChange={(e) => setEditForm({ ...editForm, bio: e.target.value })} className="md:col-span-2" />
            <div className="flex gap-2 md:col-span-2">
              <Button type="submit" disabled={savingEdit}>{savingEdit ? "Saving..." : "Save Profile"}</Button>
              <Button type="button" variant="secondary" onClick={() => setEditProvider(null)}>Cancel</Button>
            </div>
          </form>
        </Card>
      )}

      <div className="glass-table-wrap overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead>
            <tr>
              <th className="px-4 py-3">Name</th>
              <th className="px-4 py-3">Email</th>
              <th className="px-4 py-3">Skills</th>
              <th className="px-4 py-3">Experience</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {providers.map((p) => (
              <tr key={p.id} className="border-t">
                <td className="px-4 py-3 font-medium">{p.profiles?.full_name ?? "—"}</td>
                <td className="px-4 py-3">{p.profiles?.email ?? "—"}</td>
                <td className="px-4 py-3">{p.skills?.join(", ") || "—"}</td>
                <td className="px-4 py-3">{p.experience_years} yrs</td>
                <td className="px-4 py-3">
                  <span className={`rounded-full px-2 py-1 text-xs ${
                    p.status === "approved" ? "bg-green-100 text-green-700" :
                    p.status === "pending" ? "bg-yellow-100 text-yellow-700" :
                    "bg-red-100 text-red-700"
                  }`}>
                    {PROVIDER_STATUS_LABELS[p.status]}
                  </span>
                </td>
                <td className="px-4 py-3 space-x-1">
                  <Button size="sm" variant="secondary" onClick={() => startEdit(p)}>Edit</Button>
                  {p.status === "pending" && (
                    <>
                      <Button size="sm" onClick={() => handleAction(p.id, "approve")}>Approve</Button>
                      <Button size="sm" variant="danger" onClick={() => handleAction(p.id, "reject")}>Reject</Button>
                    </>
                  )}
                  {p.status === "approved" && (
                    <Button size="sm" variant="danger" onClick={() => handleAction(p.id, "suspend")}>Suspend</Button>
                  )}
                  <Button size="sm" variant="danger" onClick={() => handleDelete(p)}>Delete</Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
