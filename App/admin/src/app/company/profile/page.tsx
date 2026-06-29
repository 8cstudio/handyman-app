"use client";

import { useEffect, useState } from "react";
import { createClient, Button, Input, Card, getMyCompanyId } from "@handyman/shared";
import type { Company } from "@handyman/shared";

export default function ProfilePage() {
  const [company, setCompany] = useState<Partial<Company>>({});
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    async function load() {
      const supabase = createClient();
      const companyId = await getMyCompanyId(supabase);
      if (!companyId) return;

      const { data } = await supabase.from("companies").select("*").eq("id", companyId).single();
      if (data) setCompany(data);
    }
    load();
  }, []);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    const supabase = createClient();
    const { error } = await supabase.from("companies").update({
      name: company.name,
      description: company.description,
      email: company.email,
      phone: company.phone,
      address: company.address,
    }).eq("id", company.id!);

    setMessage(error ? error.message : "Profile updated!");
    setSaving(false);
  }

  return (
    <div>
      <h1 className="glass-page-title mb-6">Company Profile</h1>
      <Card>
        <form onSubmit={handleSave} className="grid grid-cols-1 gap-4 md:grid-cols-2">
          <Input label="Company Name" value={company.name ?? ""} onChange={(e) => setCompany({ ...company, name: e.target.value })} required />
          <Input label="Email" value={company.email ?? ""} onChange={(e) => setCompany({ ...company, email: e.target.value })} />
          <Input label="Phone" value={company.phone ?? ""} onChange={(e) => setCompany({ ...company, phone: e.target.value })} />
          <Input label="Address" value={company.address ?? ""} onChange={(e) => setCompany({ ...company, address: e.target.value })} />
          <Input label="Description" value={company.description ?? ""} onChange={(e) => setCompany({ ...company, description: e.target.value })} className="md:col-span-2" />
          <div className="md:col-span-2">
            <Button type="submit" disabled={saving}>{saving ? "Saving..." : "Save Profile"}</Button>
            {message && <p className="mt-2 text-sm text-green-600">{message}</p>}
          </div>
        </form>
      </Card>
    </div>
  );
}
