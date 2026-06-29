"use client";

import { useCallback, useEffect, useState } from "react";
import { invokeFunction, Button, Input, Card, subscribeToTables, unsubscribeChannel } from "@handyman/shared";
import type { Category } from "@handyman/shared";

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [form, setForm] = useState({ name: "", description: "" });
  const [editId, setEditId] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);

  const load = useCallback(async () => {
    const data = await invokeFunction<{ categories: Category[] }>("company-categories-crud", { method: "GET" });
    setCategories(data.categories);
  }, []);

  useEffect(() => {
    load();
    const channel = subscribeToTables("company-categories", ["categories"], load);
    return () => unsubscribeChannel(channel);
  }, [load]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (editId) {
      await invokeFunction("company-categories-crud", { method: "PUT", body: { id: editId, ...form } });
    } else {
      await invokeFunction("company-categories-crud", { method: "POST", body: form });
    }
    setShowForm(false);
    setEditId(null);
    setForm({ name: "", description: "" });
    load();
  }

  async function handleDelete(id: string) {
    if (!confirm("Delete this category?")) return;
    await invokeFunction("company-categories-crud", { method: "DELETE", body: { id } });
    load();
  }

  return (
    <div>
      <div className="mb-6 flex justify-between">
        <h1 className="glass-page-title">Categories</h1>
        <Button onClick={() => { setShowForm(true); setEditId(null); }}>Add Category</Button>
      </div>

      {showForm && (
        <Card title={editId ? "Edit" : "New Category"} className="mb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input label="Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
            <Input label="Description" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
            <div className="flex gap-2">
              <Button type="submit">{editId ? "Update" : "Create"}</Button>
              <Button variant="secondary" type="button" onClick={() => setShowForm(false)}>Cancel</Button>
            </div>
          </form>
        </Card>
      )}

      <div className="glass-table-wrap overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead>
            <tr><th className="px-4 py-3">Name</th><th className="px-4 py-3">Description</th><th className="px-4 py-3">Actions</th></tr>
          </thead>
          <tbody>
            {categories.map((c) => (
              <tr key={c.id} className="border-t">
                <td className="px-4 py-3 font-medium">{c.name}</td>
                <td className="px-4 py-3">{c.description}</td>
                <td className="px-4 py-3 space-x-2">
                  <Button size="sm" variant="secondary" onClick={() => { setEditId(c.id); setForm({ name: c.name, description: c.description ?? "" }); setShowForm(true); }}>Edit</Button>
                  <Button size="sm" variant="danger" onClick={() => handleDelete(c.id)}>Delete</Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
