import type { SupabaseClient } from "@supabase/supabase-js";

/** Current user's company id (company admin). Filters by auth user — never use bare .single() on profiles. */
export async function getMyCompanyId(
  supabase: SupabaseClient
): Promise<string | null> {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select("company_id")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.company_id) return profile.company_id as string;

  const { data: link } = await supabase
    .from("company_admins")
    .select("company_id")
    .eq("user_id", user.id)
    .maybeSingle();

  return (link?.company_id as string | undefined) ?? null;
}
