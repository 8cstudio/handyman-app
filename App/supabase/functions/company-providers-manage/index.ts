import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  errorResponse,
  getAuthUser,
  getServiceClient,
  handleCors,
  jsonResponse,
  requireRole,
} from "../_shared/utils.ts";

serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  const auth = await getAuthUser(req);
  if (auth instanceof Response) return auth;
  const { user } = auth;

  const roleCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin", "provider"]);
  if (roleCheck instanceof Response) return roleCheck;
  const { profile } = roleCheck;

  const serviceClient = getServiceClient();

  try {
    if (req.method === "GET") {
      const url = new URL(req.url);
      const companyId = url.searchParams.get("company_id") ?? profile.company_id;

      let query = serviceClient
        .from("providers")
        .select("*, profiles(full_name, email, phone, avatar_url)");

      if (companyId) query = query.eq("company_id", companyId);

      const { data, error } = await query.order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return jsonResponse({ providers: data });
    }

    const body = await req.json();

    if (req.method === "PUT") {
      const { id, action, document_id, skills, experience_years, bio } = body;
      if (!id) return errorResponse("id is required");

      if (action === "approve") {
        const adminCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
        if (adminCheck instanceof Response) return adminCheck;

        const { data, error } = await serviceClient
          .from("providers")
          .update({
            status: "approved",
            approved_at: new Date().toISOString(),
            approved_by: user.id,
          })
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return jsonResponse({ provider: data });
      }

      if (action === "reject") {
        const adminCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
        if (adminCheck instanceof Response) return adminCheck;

        const { data, error } = await serviceClient
          .from("providers")
          .update({ status: "rejected" })
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return jsonResponse({ provider: data });
      }

      if (action === "suspend") {
        const adminCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
        if (adminCheck instanceof Response) return adminCheck;

        const { data, error } = await serviceClient
          .from("providers")
          .update({ status: "suspended" })
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return jsonResponse({ provider: data });
      }

      if (action === "verify_document") {
        const adminCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
        if (adminCheck instanceof Response) return adminCheck;
        if (!document_id) return errorResponse("document_id is required");

        const { data, error } = await serviceClient
          .from("provider_documents")
          .update({
            verification_status: "verified",
            verified_at: new Date().toISOString(),
            verified_by: user.id,
          })
          .eq("id", document_id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return jsonResponse({ document: data });
      }

      if (action === "update_profile") {
        const updates: Record<string, unknown> = {};
        if (skills) updates.skills = skills;
        if (experience_years !== undefined) updates.experience_years = experience_years;
        if (bio !== undefined) updates.bio = bio;

        const { data, error } = await serviceClient
          .from("providers")
          .update(updates)
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return jsonResponse({ provider: data });
      }

      return errorResponse("Invalid action");
    }

    if (req.method === "DELETE") {
      const adminCheck = await requireRole(auth.client, user.id, ["super_admin", "company_admin"]);
      if (adminCheck instanceof Response) return adminCheck;

      const { id } = body;
      if (!id) return errorResponse("id is required");

      const { error } = await serviceClient
        .from("providers")
        .update({ status: "suspended" })
        .eq("id", id);
      if (error) throw new Error(error.message);
      return jsonResponse({ success: true });
    }

    if (req.method === "POST") {
      const { provider_id, document_type, file_url } = body;
      if (!provider_id || !document_type || !file_url) {
        return errorResponse("provider_id, document_type, and file_url are required");
      }

      const { data, error } = await serviceClient
        .from("provider_documents")
        .insert({ provider_id, document_type, file_url })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return jsonResponse({ document: data }, 201);
    }

    return errorResponse("Method not allowed", 405);
  } catch (e) {
    return errorResponse((e as Error).message, 500);
  }
});
