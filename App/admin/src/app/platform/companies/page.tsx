"use client";

import { useEffect, useState } from "react";
import { invokeFunction, Button, Input, Card, ErrorAlert } from "@handyman/shared";
import type { Company } from "@handyman/shared";

const emptyCompanyForm = { name: "", description: "", email: "", phone: "", address: "" };

const emptyAdminForm = { email: "", password: "", full_name: "", phone: "" };

export default function CompaniesPage() {
  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState(emptyCompanyForm);
  const [editId, setEditId] = useState<string | null>(null);
  const [adminCompany, setAdminCompany] = useState<Company | null>(null);
  const [adminForm, setAdminForm] = useState(emptyAdminForm);
  const [savingAdmin, setSavingAdmin] = useState(false);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  async function loadCompanies() {
    const data = await invokeFunction<{ companies: Company[] }>("admin-companies-crud", { method: "GET" });
    setCompanies(data.companies);
    setLoading(false);
  }

  useEffect(() => {
    loadCompanies().catch((err: Error) => setError(err.message));
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      if (editId) {
        await invokeFunction("admin-companies-crud", { method: "PUT", body: { id: editId, ...form } });
      } else {
        await invokeFunction("admin-companies-crud", { method: "POST", body: form });
      }
      setShowForm(false);
      setEditId(null);
      setForm(emptyCompanyForm);
      loadCompanies();
    } catch (err) {
      setError((err as Error).message);
    }
  }

  async function toggleActive(company: Company) {
    setError("");
    try {
      await invokeFunction("admin-companies-crud", {
        method: "PUT",
        body: { id: company.id, is_active: !company.is_active },
      });
      loadCompanies();
    } catch (err) {
      setError((err as Error).message);
    }
  }

  async function handleDelete(company: Company) {
    const confirmed = window.confirm(
      `Permanently delete "${company.name}"?\n\nThis removes the company, its services, providers, admin logins, and all bookings. This cannot be undone.`
    );
    if (!confirmed) return;

    setError("");
    setMessage("");
    try {
      await invokeFunction("admin-companies-crud", {
        method: "DELETE",
        body: { id: company.id },
      });
      setMessage(`Company "${company.name}" deleted.`);
      loadCompanies();
    } catch (err) {
      setError((err as Error).message);
    }
  }

  async function handleCreateAdmin(e: React.FormEvent) {
    e.preventDefault();
    if (!adminCompany) return;

    setSavingAdmin(true);
    setError("");
    setMessage("");
    try {
      await invokeFunction("auth-register-company-admin", {
        body: {
          email: adminForm.email,
          password: adminForm.password,
          full_name: adminForm.full_name,
          phone: adminForm.phone || undefined,
          company_id: adminCompany.id,
        },
      });
      setMessage(
        `Company admin created. They can sign in at /login with email ${adminForm.email} and the password you set.`
      );
      setAdminForm(emptyAdminForm);
      setAdminCompany(null);
    } catch (err) {
      setError((err as Error).message);
    }
    setSavingAdmin(false);
  }

  function startEdit(company: Company) {
    setEditId(company.id);
    setForm({
      name: company.name,
      description: company.description ?? "",
      email: company.email ?? "",
      phone: company.phone ?? "",
      address: company.address ?? "",
    });
    setShowForm(true);
  }

  function startAddAdmin(company: Company) {
    setAdminCompany(company);
    setAdminForm({
      email: company.email ?? "",
      password: "",
      full_name: `${company.name} Admin`,
      phone: company.phone ?? "",
    });
    setError("");
    setMessage("");
  }

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="glass-page-title text-[var(--color-text)]">Companies</h1>
        <Button onClick={() => { setShowForm(true); setEditId(null); }}>
          Add Company
        </Button>
      </div>

      <p className="mb-4 text-sm text-[var(--color-text-secondary)]">
        Company email is contact info only. To let someone log into the Company Admin panel, use{" "}
        <strong>Add Admin</strong> and set their login email and password.
      </p>

      {error && (
        <div className="mb-4">
          <ErrorAlert message={error} onDismiss={() => setError("")} />
        </div>
      )}
      {message && <p className="mb-4 text-sm text-green-600">{message}</p>}

      {showForm && (
        <Card title={editId ? "Edit Company" : "New Company"} className="mb-6">
          <form onSubmit={handleSubmit} className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Input label="Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
            <Input
              label="Contact email"
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
            />
            <Input label="Phone" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
            <Input label="Address" value={form.address} onChange={(e) => setForm({ ...form, address: e.target.value })} />
            <Input label="Description" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} className="md:col-span-2" />
            <div className="flex gap-2 md:col-span-2">
              <Button type="submit">{editId ? "Update" : "Create"}</Button>
              <Button variant="secondary" type="button" onClick={() => setShowForm(false)}>Cancel</Button>
            </div>
          </form>
        </Card>
      )}

      {adminCompany && (
        <Card title={`Add Company Admin — ${adminCompany.name}`} className="mb-6">
          <p className="mb-4 text-sm text-[var(--color-text-secondary)]">
            This creates a login for the web admin panel at /login. Share the email and password with the company admin.
          </p>
          <form onSubmit={handleCreateAdmin} className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Input
              label="Login email"
              type="email"
              value={adminForm.email}
              onChange={(e) => setAdminForm({ ...adminForm, email: e.target.value })}
              required
            />
            <Input
              label="Password"
              type="password"
              value={adminForm.password}
              onChange={(e) => setAdminForm({ ...adminForm, password: e.target.value })}
              required
            />
            <Input
              label="Full name"
              value={adminForm.full_name}
              onChange={(e) => setAdminForm({ ...adminForm, full_name: e.target.value })}
              required
            />
            <Input
              label="Phone (optional)"
              value={adminForm.phone}
              onChange={(e) => setAdminForm({ ...adminForm, phone: e.target.value })}
            />
            <div className="flex gap-2 md:col-span-2">
              <Button type="submit" disabled={savingAdmin}>
                {savingAdmin ? "Creating..." : "Create Admin Login"}
              </Button>
              <Button variant="secondary" type="button" onClick={() => setAdminCompany(null)}>
                Cancel
              </Button>
            </div>
          </form>
        </Card>
      )}

      {loading ? (
        <p>Loading...</p>
      ) : (
        <div className="glass-table-wrap overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead>
              <tr>
                <th className="px-4 py-3">Name</th>
                <th className="px-4 py-3">Contact email</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {companies.map((c) => (
                <tr key={c.id} className="border-t border-gray-200">
                  <td className="px-4 py-3 font-medium">{c.name}</td>
                  <td className="px-4 py-3">{c.email ?? "—"}</td>
                  <td className="px-4 py-3">
                    <span className={`rounded-full px-2 py-1 text-xs ${c.is_active ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}>
                      {c.is_active ? "Active" : "Inactive"}
                    </span>
                  </td>
                  <td className="px-4 py-3 space-x-2">
                    <Button size="sm" variant="primary" onClick={() => startAddAdmin(c)}>
                      Add Admin
                    </Button>
                    <Button size="sm" variant="secondary" onClick={() => startEdit(c)}>Edit</Button>
                    <Button size="sm" variant={c.is_active ? "danger" : "primary"} onClick={() => toggleActive(c)}>
                      {c.is_active ? "Deactivate" : "Activate"}
                    </Button>
                    <Button size="sm" variant="danger" onClick={() => handleDelete(c)}>
                      Delete
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
