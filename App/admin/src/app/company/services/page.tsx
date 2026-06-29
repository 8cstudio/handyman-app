"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import {
  invokeFunction,
  Button,
  Input,
  Card,
  subscribeToTables,
  unsubscribeChannel,
  uploadServiceImage,
} from "@handyman/shared";
import type { Service, Category } from "@handyman/shared";

const emptyForm = {
  name: "",
  description: "",
  price: "",
  duration_minutes: "60",
  category_id: "",
  image_url: "",
};

export default function ServicesPage() {
  const [services, setServices] = useState<Service[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [form, setForm] = useState(emptyForm);
  const [editId, setEditId] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const load = useCallback(async () => {
    const [svc, cat] = await Promise.all([
      invokeFunction<{ services: Service[] }>("company-services-crud", { method: "GET" }),
      invokeFunction<{ categories: Category[] }>("company-categories-crud", { method: "GET" }),
    ]);
    setServices(svc.services);
    setCategories(cat.categories);
  }, []);

  useEffect(() => {
    load();
    const channel = subscribeToTables("company-services", ["services", "categories"], load);
    return () => unsubscribeChannel(channel);
  }, [load]);

  function resetForm() {
    setForm(emptyForm);
    setEditId(null);
    setImageFile(null);
    setImagePreview(null);
    if (fileInputRef.current) fileInputRef.current.value = "";
  }

  function openCreateForm() {
    resetForm();
    setShowForm(true);
  }

  function openEditForm(service: Service) {
    setEditId(service.id);
    setForm({
      name: service.name,
      description: service.description ?? "",
      price: String(service.price),
      duration_minutes: String(service.duration_minutes),
      category_id: service.category_id,
      image_url: service.image_url ?? "",
    });
    setImageFile(null);
    setImagePreview(service.image_url ?? null);
    if (fileInputRef.current) fileInputRef.current.value = "";
    setShowForm(true);
  }

  function handleImageChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setUploading(true);
    try {
      let image_url = form.image_url || undefined;
      if (imageFile) {
        image_url = await uploadServiceImage(imageFile, editId ?? undefined);
      }

      const body = {
        name: form.name,
        description: form.description,
        price: parseFloat(form.price),
        duration_minutes: parseInt(form.duration_minutes),
        category_id: form.category_id,
        image_url,
      };

      if (editId) {
        await invokeFunction("company-services-crud", { method: "PUT", body: { id: editId, ...body } });
      } else {
        await invokeFunction("company-services-crud", { method: "POST", body });
      }

      setShowForm(false);
      resetForm();
      load();
    } finally {
      setUploading(false);
    }
  }

  return (
    <div>
      <div className="mb-6 flex justify-between">
        <h1 className="glass-page-title">Services</h1>
        <Button onClick={openCreateForm}>Add Service</Button>
      </div>

      {showForm && (
        <Card title={editId ? "Edit Service" : "New Service"} className="mb-6">
          <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4">
            <Input label="Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
            <div>
              <label className="block text-sm font-medium mb-1">Category</label>
              <select className="glass-select w-full" value={form.category_id} onChange={(e) => setForm({ ...form, category_id: e.target.value })} required>
                <option value="">Select...</option>
                {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
            </div>
            <Input label="Price" type="number" value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} required />
            <Input label="Duration (min)" type="number" value={form.duration_minutes} onChange={(e) => setForm({ ...form, duration_minutes: e.target.value })} />
            <Input label="Description" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} className="col-span-2" />
            <div className="col-span-2">
              <label className="block text-sm font-medium mb-1">Service image</label>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/jpeg,image/png,image/webp"
                onChange={handleImageChange}
                className="block w-full text-sm"
              />
              {imagePreview && (
                <img
                  src={imagePreview}
                  alt="Preview"
                  className="mt-2 h-32 w-32 rounded-lg border object-cover"
                />
              )}
            </div>
            <div className="col-span-2 flex gap-2">
              <Button type="submit" disabled={uploading}>{uploading ? "Saving..." : editId ? "Update" : "Create"}</Button>
              <Button variant="secondary" type="button" onClick={() => { setShowForm(false); resetForm(); }}>Cancel</Button>
            </div>
          </form>
        </Card>
      )}

      <div className="glass-table-wrap overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead>
            <tr>
              <th className="px-4 py-3">Image</th>
              <th className="px-4 py-3">Name</th>
              <th className="px-4 py-3">Category</th>
              <th className="px-4 py-3">Price</th>
              <th className="px-4 py-3">Duration</th>
              <th className="px-4 py-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {services.map((s) => (
              <tr key={s.id} className="border-t">
                <td className="px-4 py-3">
                  {s.image_url ? (
                    <img src={s.image_url} alt={s.name} className="h-10 w-10 rounded object-cover" />
                  ) : (
                    <span className="text-[var(--color-text-secondary)]">—</span>
                  )}
                </td>
                <td className="px-4 py-3 font-medium">{s.name}</td>
                <td className="px-4 py-3">{s.categories?.name}</td>
                <td className="px-4 py-3">${s.price}</td>
                <td className="px-4 py-3">{s.duration_minutes} min</td>
                <td className="px-4 py-3 space-x-2">
                  <Button size="sm" variant="secondary" onClick={() => openEditForm(s)}>Edit</Button>
                  <Button size="sm" variant="danger" onClick={async () => { await invokeFunction("company-services-crud", { method: "DELETE", body: { id: s.id } }); load(); }}>Deactivate</Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
