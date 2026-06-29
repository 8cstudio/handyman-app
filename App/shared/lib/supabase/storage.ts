import { getMyCompanyId } from "../auth/company-context";
import { createClient } from "./client";

export async function uploadServiceImage(
  file: File,
  serviceId?: string
): Promise<string> {
  const supabase = createClient();
  const companyId = await getMyCompanyId(supabase);
  if (!companyId) throw new Error("No company assigned");

  const ext = file.name.split(".").pop()?.toLowerCase() ?? "jpg";
  const id = serviceId ?? crypto.randomUUID();
  const path = `${companyId}/${id}-${Date.now()}.${ext}`;

  const { error } = await supabase.storage
    .from("service-images")
    .upload(path, file, { upsert: true, contentType: file.type });

  if (error) throw new Error(error.message);

  const { data } = supabase.storage.from("service-images").getPublicUrl(path);
  return data.publicUrl;
}
