import type { NextRequest } from "next/server";
import type { NextResponse } from "next/server";
import { apiError, apiJson } from "./api-response";
import { buildAuthUserPayload, formatAuthErrorMessage } from "./auth-helpers";
import {
  ensureChatRoom,
  getAuthFromRequest,
  logBookingStatus,
  requireRole,
} from "./request-auth";
import { getServiceClient } from "./supabase-admin";
import {
  formatBookingStatus,
  getBookingParticipantUserIds,
  notifyUsersAsync,
} from "./push-notifications";

export const PUBLIC_HANDLERS = new Set([
  "auth-sign-in",
  "auth-register-customer",
  "auth-forgot-password",
]);

const PROVIDER_TRANSITIONS: Record<string, string[]> = {
  assigned: ["accepted", "rejected"],
  accepted: ["in_progress"],
  in_progress: ["completed"],
};

const ADMIN_TRANSITIONS: Record<string, string[]> = {
  pending: ["cancelled"],
  assigned: ["cancelled"],
  accepted: ["cancelled"],
  in_progress: ["cancelled"],
};

const CHAT_ALLOWED_BOOKING_STATUSES = new Set([
  "accepted",
  "in_progress",
  "completed",
]);

const PROVIDER_PROFILE_EMBED =
  "profiles!providers_user_id_fkey(full_name, phone, avatar_url)";
const PROVIDER_WITH_PROFILE = `*, ${PROVIDER_PROFILE_EMBED}`;
const NESTED_PROVIDER_PROFILE = `providers(${PROVIDER_PROFILE_EMBED})`;

async function enrichProvidersWithEmail<T extends { user_id: string; profiles?: Record<string, unknown> | null }>(
  serviceClient: ReturnType<typeof getServiceClient>,
  providers: T[]
): Promise<T[]> {
  return Promise.all(
    providers.map(async (provider) => {
      const { data } = await serviceClient.auth.admin.getUserById(provider.user_id);
      const email = data.user?.email ?? null;
      return {
        ...provider,
        profiles: {
          ...(provider.profiles ?? {}),
          email,
        },
      };
    })
  );
}

async function deleteProviderRecord(
  serviceClient: ReturnType<typeof getServiceClient>,
  providerId: string,
  scopeCompanyId?: string
) {
  const { data: provider, error: fetchError } = await serviceClient
    .from("providers")
    .select("id, user_id, company_id")
    .eq("id", providerId)
    .single();
  if (fetchError || !provider) throw new Error("Provider not found");

  if (scopeCompanyId && provider.company_id !== scopeCompanyId) {
    throw new Error("You can only delete providers in your company");
  }

  const { error } = await serviceClient.auth.admin.deleteUser(provider.user_id as string);
  if (error) throw new Error(error.message);
}

async function deleteCompanyRecord(
  serviceClient: ReturnType<typeof getServiceClient>,
  companyId: string
) {
  const { data: company, error: companyFetchError } = await serviceClient
    .from("companies")
    .select("id")
    .eq("id", companyId)
    .single();
  if (companyFetchError || !company) throw new Error("Company not found");

  const { data: admins } = await serviceClient
    .from("company_admins")
    .select("user_id")
    .eq("company_id", companyId);
  const { data: providers } = await serviceClient
    .from("providers")
    .select("user_id")
    .eq("company_id", companyId);

  const userIds = [
    ...new Set([
      ...(admins ?? []).map((a) => a.user_id as string),
      ...(providers ?? []).map((p) => p.user_id as string),
    ]),
  ];

  const { error: bookingsError } = await serviceClient
    .from("bookings")
    .delete()
    .eq("company_id", companyId);
  if (bookingsError) throw new Error(bookingsError.message);

  const { error: companyError } = await serviceClient
    .from("companies")
    .delete()
    .eq("id", companyId);
  if (companyError) throw new Error(companyError.message);

  for (const userId of userIds) {
    await serviceClient.auth.admin.deleteUser(userId);
  }
}

type Handler = (request: NextRequest) => Promise<NextResponse>;

async function parseBody(request: NextRequest): Promise<Record<string, unknown>> {
  try {
    return (await request.json()) as Record<string, unknown>;
  } catch {
    return {};
  }
}

async function requireAuth(request: NextRequest) {
  const auth = await getAuthFromRequest(request);
  if (!auth) {
    return { response: apiError("Unauthorized", 401) } as const;
  }
  return { auth } as const;
}

async function withRole(
  auth: NonNullable<Awaited<ReturnType<typeof getAuthFromRequest>>>,
  roles: string[]
) {
  try {
    const { profile } = await requireRole(auth.client, auth.user.id, roles);
    return { profile } as const;
  } catch (e) {
    if ((e as Error).message === "Forbidden") {
      return { response: apiError("Forbidden", 403) } as const;
    }
    throw e;
  }
}

async function handleAuthSignIn(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  try {
    const body = await parseBody(request);
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";

    if (!email || !password) {
      return apiError("Email and password are required", 400);
    }

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";

    const tokenResponse = await fetch(
      `${supabaseUrl}/auth/v1/token?grant_type=password`,
      {
        method: "POST",
        headers: {
          apikey: supabaseAnonKey,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      }
    );

    const tokenData = await tokenResponse.json();

    if (!tokenResponse.ok) {
      const message = formatAuthErrorMessage(
        (tokenData.error_description as string | undefined) ??
          (tokenData.msg as string | undefined) ??
          (tokenData.error as string | undefined) ??
          "Sign in failed"
      );
      return apiError(message, 401);
    }

    const allowedRoles = ["customer", "provider"];
    const serviceClient = getServiceClient();
    const userPayload = await buildAuthUserPayload(
      serviceClient,
      tokenData.user.id as string,
      email,
      {
        access_token: tokenData.access_token as string,
        refresh_token: tokenData.refresh_token as string,
        expires_in: tokenData.expires_in as number | undefined,
      }
    );

    if (!allowedRoles.includes(userPayload.role)) {
      return apiError("This account cannot sign in through the mobile app.", 403);
    }

    return apiJson({ user: userPayload });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAuthRegisterCustomer(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  try {
    const body = await parseBody(request);
    const email = body.email as string | undefined;
    const password = body.password as string | undefined;
    const full_name = body.full_name as string | undefined;
    const phone = body.phone as string | undefined;
    const company_id = body.company_id as string | undefined;

    if (!email || !password || !full_name) {
      return apiError("email, password, and full_name are required");
    }

    const serviceClient = getServiceClient();

    const { data: authData, error: authError } =
      await serviceClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name, role: "customer" },
      });

    if (authError) return apiError(authError.message, 400);

    const userId = authData.user!.id;

    await serviceClient.from("profiles").insert({
      id: userId,
      role: "customer",
      full_name,
      phone: phone ?? null,
      company_id: company_id ?? "a0000000-0000-4000-8000-000000000001",
    });

    await serviceClient.from("customers").insert({
      user_id: userId,
    });

    return apiJson({ user: { id: userId, email, full_name, role: "customer" } }, 201);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAuthForgotPassword(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  try {
    const body = await parseBody(request);
    const email = typeof body.email === "string" ? body.email.trim() : "";

    if (!email) {
      return apiError("Email is required", 400);
    }

    const redirectTo =
      typeof body.redirect_to === "string" && body.redirect_to.length > 0
        ? body.redirect_to
        : "handyman://reset-password";

    const serviceClient = getServiceClient();
    const { error } = await serviceClient.auth.resetPasswordForEmail(email, {
      redirectTo,
    });

    if (error) {
      return apiError(error.message, 400);
    }

    return apiJson({
      message:
        "If an account exists for this email, password reset instructions have been sent.",
    });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAuthMe(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "GET" && request.method !== "POST") {
    return apiError("Method not allowed", 405);
  }

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  try {
    const serviceClient = getServiceClient();
    const userPayload = await buildAuthUserPayload(
      serviceClient,
      auth.user.id,
      auth.user.email ?? ""
    );

    return apiJson({ user: userPayload });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAuthRegisterProvider(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin", "company_admin"]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  try {
    const body = await parseBody(request);
    const email = body.email as string | undefined;
    const password = body.password as string | undefined;
    const full_name = body.full_name as string | undefined;
    const phone = body.phone as string | undefined;
    const company_id = body.company_id as string | undefined;
    const skills = body.skills as string[] | undefined;
    const experience_years = body.experience_years as number | undefined;
    const bio = body.bio as string | undefined;

    const resolvedCompanyId =
      profile.role === "company_admin"
        ? (profile.company_id as string)
        : company_id;

    if (!email || !password || !full_name || !resolvedCompanyId) {
      return apiError(
        "email, password, full_name, and company_id are required",
        400
      );
    }

    const serviceClient = getServiceClient();

    const { data: company } = await serviceClient
      .from("companies")
      .select("id, is_active")
      .eq("id", resolvedCompanyId)
      .single();

    if (!company || !company.is_active) {
      return apiError("Invalid or inactive company", 400);
    }

    const { data: authData, error: authError } =
      await serviceClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name, role: "provider" },
      });

    if (authError) return apiError(authError.message, 400);

    const userId = authData.user!.id;

    await serviceClient.from("profiles").insert({
      id: userId,
      role: "provider",
      full_name,
      phone: phone ?? null,
      company_id: resolvedCompanyId,
    });

    const { data: provider, error: providerError } = await serviceClient
      .from("providers")
      .insert({
        user_id: userId,
        company_id: resolvedCompanyId,
        skills: skills ?? [],
        experience_years: experience_years ?? 0,
        bio: bio ?? null,
        status: "approved",
        approved_at: new Date().toISOString(),
        approved_by: auth.user.id,
      })
      .select(PROVIDER_WITH_PROFILE)
      .single();

    if (providerError) throw new Error(providerError.message);

    return apiJson(
      {
        user: { id: userId, email, full_name, role: "provider" },
        provider,
      },
      201
    );
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAuthRegisterCompanyAdmin(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin"]);
  if ("response" in roleResult) return roleResult.response;

  try {
    const body = await parseBody(request);
    const email = body.email as string | undefined;
    const password = body.password as string | undefined;
    const full_name = body.full_name as string | undefined;
    const phone = body.phone as string | undefined;
    const company_id = body.company_id as string | undefined;

    if (!email || !password || !full_name || !company_id) {
      return apiError("email, password, full_name, and company_id are required");
    }

    const serviceClient = getServiceClient();

    const { data: authData, error: authError } =
      await serviceClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name, role: "company_admin" },
      });

    if (authError) return apiError(authError.message, 400);

    const userId = authData.user!.id;

    await serviceClient.from("profiles").insert({
      id: userId,
      role: "company_admin",
      full_name,
      phone: phone ?? null,
      company_id,
    });

    await serviceClient.from("company_admins").insert({
      user_id: userId,
      company_id,
    });

    return apiJson(
      {
        user: { id: userId, email, full_name, role: "company_admin", company_id },
      },
      201
    );
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleBookingsList(request: NextRequest): Promise<NextResponse> {
  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, [
    "super_admin",
    "company_admin",
    "customer",
    "provider",
  ]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    if (request.method === "GET") {
      const status = request.nextUrl.searchParams.get("status");
      const page = Math.max(0, parseInt(request.nextUrl.searchParams.get("page") ?? "0", 10));
      const pageSize = Math.min(
        100,
        Math.max(1, parseInt(request.nextUrl.searchParams.get("page_size") ?? "20", 10))
      );

      let query = serviceClient
        .from("bookings")
        .select(`
          *,
          services(name, price, duration_minutes),
          customers(profiles(full_name, phone)),
          ${NESTED_PROVIDER_PROFILE}
        `)
        .order("created_at", { ascending: false });

      if (status) query = query.eq("status", status);

      if (profile.role === "company_admin") {
        query = query.eq("company_id", profile.company_id as string);
      } else if (profile.role === "customer") {
        const { data: customer } = await serviceClient
          .from("customers")
          .select("id")
          .eq("user_id", auth.user.id)
          .single();
        if (customer) query = query.eq("customer_id", customer.id);
      } else if (profile.role === "provider") {
        const { data: provider } = await serviceClient
          .from("providers")
          .select("id")
          .eq("user_id", auth.user.id)
          .single();
        if (provider) query = query.eq("provider_id", provider.id);
      }

      const from = page * pageSize;
      const to = from + pageSize;
      const { data, error } = await query.range(from, to);
      if (error) throw new Error(error.message);

      const rows = data ?? [];
      const hasMore = rows.length > pageSize;
      const bookings = hasMore ? rows.slice(0, pageSize) : rows;
      return apiJson({ bookings, has_more: hasMore });
    }

    return apiError("Method not allowed", 405);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleBookingsCreate(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["customer"]);
  if ("response" in roleResult) return roleResult.response;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const service_id = body.service_id as string | undefined;
    const scheduled_at = body.scheduled_at as string | undefined;
    const address = body.address as string | undefined;
    const notes = body.notes as string | undefined;

    if (!service_id || !scheduled_at || !address) {
      return apiError("service_id, scheduled_at, and address are required");
    }

    const { data: customer } = await serviceClient
      .from("customers")
      .select("id")
      .eq("user_id", auth.user.id)
      .single();

    if (!customer) return apiError("Customer profile not found", 404);

    const { data: service } = await serviceClient
      .from("services")
      .select("company_id")
      .eq("id", service_id)
      .single();

    if (!service) return apiError("Service not found", 404);

    const { data: booking, error } = await serviceClient
      .from("bookings")
      .insert({
        company_id: service.company_id,
        service_id,
        customer_id: customer.id,
        scheduled_at,
        address,
        notes,
        status: "pending",
      })
      .select("*, services(name, price), customers(profiles(full_name))")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(
      booking.id,
      null,
      "pending",
      auth.user.id,
      "Booking created"
    );

    return apiJson({ booking }, 201);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleBookingsAssign(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin", "company_admin"]);
  if ("response" in roleResult) return roleResult.response;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const booking_id = body.booking_id as string | undefined;
    const provider_id = body.provider_id as string | undefined;

    if (!booking_id || !provider_id) {
      return apiError("booking_id and provider_id are required");
    }

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("status")
      .eq("id", booking_id)
      .single();

    if (!booking) return apiError("Booking not found", 404);

    const oldStatus = booking.status as string;

    if (!["pending", "assigned", "rejected"].includes(oldStatus)) {
      return apiError(
        "Can only assign or re-assign bookings that are pending, assigned, or rejected",
        400
      );
    }

    const isReassign = oldStatus === "assigned" || oldStatus === "rejected";

    const { data: updated, error } = await serviceClient
      .from("bookings")
      .update({ provider_id, status: "assigned" })
      .eq("id", booking_id)
      .select(`*, services(name), ${NESTED_PROVIDER_PROFILE}`)
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(
      booking_id,
      oldStatus,
      "assigned",
      auth.user.id,
      isReassign ? "Provider re-assigned" : "Provider assigned"
    );

    const { customerUserId, providerUserId } = await getBookingParticipantUserIds(
      serviceClient,
      booking_id
    );
    notifyUsersAsync(serviceClient, [customerUserId], {
      title: "Provider assigned",
      body: isReassign
        ? "A new provider has been assigned to your booking."
        : "A provider has been assigned to your booking.",
      data: { type: "booking_status", booking_id, status: "assigned" },
    });
    notifyUsersAsync(serviceClient, [providerUserId], {
      title: "New booking assigned",
      body: "You have been assigned a new service booking.",
      data: { type: "booking_status", booking_id, status: "assigned" },
    });

    return apiJson({ booking: updated });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleBookingsUpdateStatus(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const booking_id = body.booking_id as string | undefined;
    const status = body.status as string | undefined;
    const note = body.note as string | undefined;

    if (!booking_id || !status) {
      return apiError("booking_id and status are required");
    }

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("*, customers(user_id), providers(user_id)")
      .eq("id", booking_id)
      .single();

    if (!booking) return apiError("Booking not found", 404);

    const profileResult = await serviceClient
      .from("profiles")
      .select("role")
      .eq("id", auth.user.id)
      .single();
    const role = profileResult.data?.role as string | undefined;
    const bookingStatus = booking.status as string;
    const providerUserId = (booking.providers as { user_id?: string } | null)
      ?.user_id;

    let allowed = false;
    if (role === "provider" && providerUserId === auth.user.id) {
      allowed = PROVIDER_TRANSITIONS[bookingStatus]?.includes(status) ?? false;
    } else if (role === "company_admin" || role === "super_admin") {
      allowed = ADMIN_TRANSITIONS[bookingStatus]?.includes(status) ?? false;
      if (["assigned", "accepted", "in_progress", "completed"].includes(status)) {
        allowed = true;
      }
    }

    if (!allowed) {
      return apiError(`Cannot transition from ${bookingStatus} to ${status}`, 403);
    }

    const oldStatus = bookingStatus;

    const { data: updated, error } = await serviceClient
      .from("bookings")
      .update({ status })
      .eq("id", booking_id)
      .select("*")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(booking_id, oldStatus, status, auth.user.id, note);

    if (status === "accepted") {
      await ensureChatRoom(booking_id);
    }

    const customerUserId = (booking.customers as { user_id?: string } | null)
      ?.user_id;
    const statusLabel = formatBookingStatus(status);

    if (role === "provider") {
      notifyUsersAsync(serviceClient, [customerUserId], {
        title: "Booking update",
        body: `Your provider updated the booking to ${statusLabel}.`,
        data: { type: "booking_status", booking_id, status },
      });
    } else if (role === "company_admin" || role === "super_admin") {
      notifyUsersAsync(serviceClient, [customerUserId, providerUserId], {
        title: "Booking update",
        body: `Booking status changed to ${statusLabel}.`,
        data: { type: "booking_status", booking_id, status },
      });
    }

    return apiJson({ booking: updated });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleBookingsCancel(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const booking_id = body.booking_id as string | undefined;
    const reason = body.reason as string | undefined;

    if (!booking_id) return apiError("booking_id is required");

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("*, customers(user_id)")
      .eq("id", booking_id)
      .single();

    if (!booking) return apiError("Booking not found", 404);

    const profileResult = await serviceClient
      .from("profiles")
      .select("role")
      .eq("id", auth.user.id)
      .single();
    const role = profileResult.data?.role as string | undefined;
    const customerUserId = (booking.customers as { user_id?: string } | null)
      ?.user_id;
    const bookingStatus = booking.status as string;

    const canCancel =
      role === "company_admin" ||
      role === "super_admin" ||
      (role === "customer" && customerUserId === auth.user.id);

    if (!canCancel) return apiError("Forbidden", 403);
    if (["completed", "cancelled"].includes(bookingStatus)) {
      return apiError("Booking cannot be cancelled", 400);
    }

    const oldStatus = bookingStatus;

    const { data: updated, error } = await serviceClient
      .from("bookings")
      .update({ status: "cancelled" })
      .eq("id", booking_id)
      .select("*")
      .single();

    if (error) throw new Error(error.message);

    await logBookingStatus(
      booking_id,
      oldStatus,
      "cancelled",
      auth.user.id,
      reason
    );

    return apiJson({ booking: updated });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleReviewsSubmit(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["customer"]);
  if ("response" in roleResult) return roleResult.response;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const booking_id = body.booking_id as string | undefined;
    const rating = body.rating as number | undefined;
    const comment = body.comment as string | undefined;

    if (!booking_id || !rating) {
      return apiError("booking_id and rating (1-5) are required");
    }

    if (rating < 1 || rating > 5) {
      return apiError("rating must be between 1 and 5");
    }

    const { data: customer } = await serviceClient
      .from("customers")
      .select("id")
      .eq("user_id", auth.user.id)
      .single();

    if (!customer) return apiError("Customer profile not found", 404);

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("status, provider_id, customer_id")
      .eq("id", booking_id)
      .single();

    if (!booking) return apiError("Booking not found", 404);
    if (booking.status !== "completed") {
      return apiError("Can only review completed bookings", 400);
    }
    if (booking.customer_id !== customer.id) {
      return apiError("Forbidden", 403);
    }
    if (!booking.provider_id) {
      return apiError("No provider assigned to this booking", 400);
    }

    const { data: existing } = await serviceClient
      .from("reviews")
      .select("id")
      .eq("booking_id", booking_id)
      .maybeSingle();

    if (existing) return apiError("Review already submitted", 400);

    const { data: review, error } = await serviceClient
      .from("reviews")
      .insert({
        booking_id,
        customer_id: customer.id,
        provider_id: booking.provider_id,
        rating,
        comment: comment ?? null,
      })
      .select("*")
      .single();

    if (error) throw new Error(error.message);

    return apiJson({ review }, 201);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleChatSendMessage(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const chat_room_id = body.chat_room_id as string | undefined;
    const content = body.content as string | undefined;
    const message_type =
      typeof body.message_type === "string" ? body.message_type : "text";

    if (!chat_room_id || !content) {
      return apiError("chat_room_id and content are required");
    }

    const { data: room } = await serviceClient
      .from("chat_rooms")
      .select("booking_id")
      .eq("id", chat_room_id)
      .single();

    if (!room) return apiError("Chat room not found", 404);

    const { data: booking } = await serviceClient
      .from("bookings")
      .select("status")
      .eq("id", room.booking_id)
      .single();

    if (!booking || !CHAT_ALLOWED_BOOKING_STATUSES.has(booking.status as string)) {
      return apiError("Chat is available after the provider accepts the order", 403);
    }

    const { data: message, error } = await serviceClient
      .from("messages")
      .insert({
        chat_room_id,
        sender_id: auth.user.id,
        content,
        message_type,
      })
      .select("*, profiles(full_name, avatar_url)")
      .single();

    if (error) throw new Error(error.message);

    const { customerUserId, providerUserId } = await getBookingParticipantUserIds(
      serviceClient,
      room.booking_id as string
    );
    const senderName =
      ((message.profiles as { full_name?: string } | null)?.full_name?.trim()) ||
      "Someone";
    const recipientUserId =
      auth.user.id === customerUserId ? providerUserId : customerUserId;

    notifyUsersAsync(serviceClient, [recipientUserId], {
      title: "New message",
      body: `${senderName}: ${content.length > 120 ? `${content.slice(0, 117)}...` : content}`,
      data: {
        type: "chat",
        booking_id: room.booking_id as string,
      },
    });

    return apiJson({ message }, 201);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleChatMarkRead(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const chat_room_id = body.chat_room_id as string | undefined;
    const message_ids = body.message_ids as string[] | undefined;

    if (!chat_room_id) return apiError("chat_room_id is required");

    let query = serviceClient
      .from("messages")
      .update({ read_at: new Date().toISOString() })
      .eq("chat_room_id", chat_room_id)
      .neq("sender_id", auth.user.id)
      .is("read_at", null);

    if (message_ids?.length) {
      query = query.in("id", message_ids);
    }

    const { error } = await query;
    if (error) throw new Error(error.message);

    return apiJson({ success: true });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleCompanyProvidersManage(
  request: NextRequest
): Promise<NextResponse> {
  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin", "company_admin", "provider"]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    if (request.method === "GET") {
      const companyId =
        request.nextUrl.searchParams.get("company_id") ??
        (profile.company_id as string | null);

      let query = serviceClient.from("providers").select(PROVIDER_WITH_PROFILE);

      if (companyId) query = query.eq("company_id", companyId);

      const { data, error } = await query.order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      const providers = await enrichProvidersWithEmail(serviceClient, data ?? []);
      return apiJson({ providers });
    }

    const body = await parseBody(request);

    if (request.method === "PUT") {
      const id = body.id as string | undefined;
      const action = body.action as string | undefined;
      const document_id = body.document_id as string | undefined;
      const skills = body.skills as string[] | undefined;
      const experience_years = body.experience_years as number | undefined;
      const bio = body.bio as string | undefined;
      const full_name = body.full_name as string | undefined;
      const phone = body.phone as string | undefined;

      if (!id) return apiError("id is required");

      if (action === "approve") {
        const adminResult = await withRole(auth, ["super_admin", "company_admin"]);
        if ("response" in adminResult) return adminResult.response;

        const { data, error } = await serviceClient
          .from("providers")
          .update({
            status: "approved",
            approved_at: new Date().toISOString(),
            approved_by: auth.user.id,
          })
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return apiJson({ provider: data });
      }

      if (action === "reject") {
        const adminResult = await withRole(auth, ["super_admin", "company_admin"]);
        if ("response" in adminResult) return adminResult.response;

        const { data, error } = await serviceClient
          .from("providers")
          .update({ status: "rejected" })
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return apiJson({ provider: data });
      }

      if (action === "suspend") {
        const adminResult = await withRole(auth, ["super_admin", "company_admin"]);
        if ("response" in adminResult) return adminResult.response;

        const { data, error } = await serviceClient
          .from("providers")
          .update({ status: "suspended" })
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return apiJson({ provider: data });
      }

      if (action === "verify_document") {
        const adminResult = await withRole(auth, ["super_admin", "company_admin"]);
        if ("response" in adminResult) return adminResult.response;
        if (!document_id) return apiError("document_id is required");

        const { data, error } = await serviceClient
          .from("provider_documents")
          .update({
            verification_status: "verified",
            verified_at: new Date().toISOString(),
            verified_by: auth.user.id,
          })
          .eq("id", document_id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return apiJson({ document: data });
      }

      if (action === "update_profile") {
        const adminResult = await withRole(auth, ["super_admin", "company_admin"]);
        if ("response" in adminResult) return adminResult.response;

        const { data: existing, error: existingError } = await serviceClient
          .from("providers")
          .select("id, user_id, company_id")
          .eq("id", id)
          .single();
        if (existingError || !existing) return apiError("Provider not found", 404);

        if (
          adminResult.profile.role === "company_admin" &&
          existing.company_id !== adminResult.profile.company_id
        ) {
          return apiError("You can only update providers in your company", 403);
        }

        const providerUpdates: Record<string, unknown> = {};
        if (skills) providerUpdates.skills = skills;
        if (experience_years !== undefined) providerUpdates.experience_years = experience_years;
        if (bio !== undefined) providerUpdates.bio = bio;

        if (Object.keys(providerUpdates).length > 0) {
          const { error: providerError } = await serviceClient
            .from("providers")
            .update(providerUpdates)
            .eq("id", id);
          if (providerError) throw new Error(providerError.message);
        }

        if (full_name !== undefined || phone !== undefined) {
          const profileUpdates: Record<string, unknown> = {};
          if (full_name !== undefined) profileUpdates.full_name = full_name;
          if (phone !== undefined) profileUpdates.phone = phone;

          const { error: profileError } = await serviceClient
            .from("profiles")
            .update(profileUpdates)
            .eq("id", existing.user_id);
          if (profileError) throw new Error(profileError.message);
        }

        const { data, error } = await serviceClient
          .from("providers")
          .select(PROVIDER_WITH_PROFILE)
          .eq("id", id)
          .single();
        if (error) throw new Error(error.message);

        const [enriched] = await enrichProvidersWithEmail(serviceClient, [data]);
        return apiJson({ provider: enriched });
      }

      return apiError("Invalid action");
    }

    if (request.method === "DELETE") {
      const adminResult = await withRole(auth, ["super_admin", "company_admin"]);
      if ("response" in adminResult) return adminResult.response;

      const id = body.id as string | undefined;
      if (!id) return apiError("id is required");

      const scopeCompanyId =
        adminResult.profile.role === "company_admin"
          ? (adminResult.profile.company_id as string | null)
          : null;
      if (adminResult.profile.role === "company_admin" && !scopeCompanyId) {
        return apiError("Company admin has no company assigned", 403);
      }

      await deleteProviderRecord(
        serviceClient,
        id,
        adminResult.profile.role === "company_admin" ? scopeCompanyId! : undefined
      );
      return apiJson({ success: true });
    }

    if (request.method === "POST") {
      const provider_id = body.provider_id as string | undefined;
      const document_type = body.document_type as string | undefined;
      const file_url = body.file_url as string | undefined;

      if (!provider_id || !document_type || !file_url) {
        return apiError("provider_id, document_type, and file_url are required");
      }

      const { data, error } = await serviceClient
        .from("provider_documents")
        .insert({ provider_id, document_type, file_url })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ document: data }, 201);
    }

    return apiError("Method not allowed", 405);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleCompanyServicesCrud(request: NextRequest): Promise<NextResponse> {
  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, [
    "super_admin",
    "company_admin",
    "customer",
    "provider",
  ]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    if (request.method === "GET") {
      const serviceId = request.nextUrl.searchParams.get("id");
      if (serviceId) {
        const { data, error } = await serviceClient
          .from("services")
          .select("*, categories(name)")
          .eq("id", serviceId)
          .eq("is_active", true)
          .maybeSingle();
        if (error) throw new Error(error.message);
        if (!data) return apiError("Service not found", 404);
        return apiJson({ service: data });
      }

      const companyId =
        request.nextUrl.searchParams.get("company_id") ??
        (profile.company_id as string | null);
      const categoryId = request.nextUrl.searchParams.get("category_id");
      const search = request.nextUrl.searchParams.get("search");
      const page = Math.max(0, parseInt(request.nextUrl.searchParams.get("page") ?? "0", 10));
      const pageSize = Math.min(
        100,
        Math.max(1, parseInt(request.nextUrl.searchParams.get("page_size") ?? "20", 10))
      );

      let query = serviceClient
        .from("services")
        .select("*, categories(name)")
        .eq("is_active", true);

      if (companyId) query = query.eq("company_id", companyId);
      if (categoryId) query = query.eq("category_id", categoryId);
      if (search) {
        query = query.textSearch("search_vector", search, {
          type: "websearch",
          config: "english",
        });
      }

      const from = page * pageSize;
      const to = from + pageSize;
      const { data, error } = await query.order("name").range(from, to);
      if (error) throw new Error(error.message);

      const rows = data ?? [];
      const hasMore = rows.length > pageSize;
      const services = hasMore ? rows.slice(0, pageSize) : rows;
      return apiJson({ services, has_more: hasMore });
    }

    const writeRoleResult = await withRole(auth, ["super_admin", "company_admin"]);
    if ("response" in writeRoleResult) return writeRoleResult.response;

    const body = await parseBody(request);
    const companyId = (body.company_id as string | undefined) ?? profile.company_id;

    if (request.method === "POST") {
      const category_id = body.category_id as string | undefined;
      const name = body.name as string | undefined;
      const description = body.description as string | undefined;
      const price = body.price as number | undefined;
      const duration_minutes = body.duration_minutes as number | undefined;
      const image_url = body.image_url as string | undefined;

      if (!category_id || !name || !companyId) {
        return apiError("category_id, name, and company_id are required");
      }

      const { data, error } = await serviceClient
        .from("services")
        .insert({
          company_id: companyId,
          category_id,
          name,
          description,
          price: price ?? 0,
          duration_minutes: duration_minutes ?? 60,
          image_url,
        })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ service: data }, 201);
    }

    if (request.method === "PUT") {
      const { id, ...updates } = body;
      if (!id) return apiError("id is required");

      const { data, error } = await serviceClient
        .from("services")
        .update(updates)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ service: data });
    }

    if (request.method === "DELETE") {
      const id = body.id as string | undefined;
      if (!id) return apiError("id is required");

      const { error } = await serviceClient
        .from("services")
        .update({ is_active: false })
        .eq("id", id);
      if (error) throw new Error(error.message);
      return apiJson({ success: true });
    }

    return apiError("Method not allowed", 405);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleCompanyCategoriesCrud(
  request: NextRequest
): Promise<NextResponse> {
  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin", "company_admin"]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  let body: Record<string, unknown> = {};
  if (request.method !== "GET" || profile.role === "super_admin") {
    body = await parseBody(request);
  }

  const companyId =
    profile.role === "super_admin"
      ? (body.company_id as string | undefined)
      : (profile.company_id as string | undefined);

  const serviceClient = getServiceClient();

  try {
    if (request.method === "GET") {
      const cid =
        request.nextUrl.searchParams.get("company_id") ?? companyId;
      const { data, error } = await serviceClient
        .from("categories")
        .select("*")
        .eq("company_id", cid)
        .order("sort_order");
      if (error) throw new Error(error.message);
      return apiJson({ categories: data });
    }

    const cid = (body.company_id as string | undefined) ?? companyId;

    if (request.method === "POST") {
      const name = body.name as string | undefined;
      const description = body.description as string | undefined;
      const image_url = body.image_url as string | undefined;
      const sort_order = body.sort_order as number | undefined;

      if (!name || !cid) return apiError("name and company_id are required");

      const { data, error } = await serviceClient
        .from("categories")
        .insert({
          company_id: cid,
          name,
          description,
          image_url,
          sort_order: sort_order ?? 0,
        })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ category: data }, 201);
    }

    if (request.method === "PUT") {
      const { id, ...updates } = body;
      if (!id) return apiError("id is required");

      const { data, error } = await serviceClient
        .from("categories")
        .update(updates)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ category: data });
    }

    if (request.method === "DELETE") {
      const id = body.id as string | undefined;
      if (!id) return apiError("id is required");

      const { error } = await serviceClient.from("categories").delete().eq("id", id);
      if (error) throw new Error(error.message);
      return apiJson({ success: true });
    }

    return apiError("Method not allowed", 405);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handlePlatformSettingsPublic(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") {
    return apiError("Method not allowed", 405);
  }

  const serviceClient = getServiceClient();

  try {
    const { data, error } = await serviceClient
      .from("platform_settings")
      .select("id, platform_name, theme_config, updated_at")
      .limit(1)
      .single();
    if (error) throw new Error(error.message);
    return apiJson({ settings: data });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAdminPlatformSettings(
  request: NextRequest
): Promise<NextResponse> {
  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin"]);
  if ("response" in roleResult) return roleResult.response;

  const serviceClient = getServiceClient();

  try {
    if (request.method === "GET") {
      const { data, error } = await serviceClient
        .from("platform_settings")
        .select("*")
        .limit(1)
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ settings: data });
    }

    if (request.method === "PUT") {
      const body = await parseBody(request);
      const platform_name = body.platform_name as string | undefined;
      const theme_config = body.theme_config as unknown;

      const updates: Record<string, unknown> = {
        updated_at: new Date().toISOString(),
        updated_by: auth.user.id,
      };
      if (platform_name) updates.platform_name = platform_name;
      if (theme_config) updates.theme_config = theme_config;

      const { data: existing, error: fetchError } = await serviceClient
        .from("platform_settings")
        .select("id")
        .limit(1)
        .single();
      if (fetchError) throw new Error(fetchError.message);

      const { data, error } = await serviceClient
        .from("platform_settings")
        .update(updates)
        .eq("id", existing.id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ settings: data });
    }

    return apiError("Method not allowed", 405);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleAdminCompaniesCrud(request: NextRequest): Promise<NextResponse> {
  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin"]);
  if ("response" in roleResult) return roleResult.response;

  const serviceClient = getServiceClient();

  try {
    if (request.method === "GET") {
      const { data, error } = await serviceClient
        .from("companies")
        .select("*")
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return apiJson({ companies: data });
    }

    if (request.method === "POST") {
      const body = await parseBody(request);
      const name = body.name as string | undefined;
      const description = body.description as string | undefined;
      const email = body.email as string | undefined;
      const phone = body.phone as string | undefined;
      const address = body.address as string | undefined;

      if (!name) return apiError("name is required");

      const { data, error } = await serviceClient
        .from("companies")
        .insert({ name, description, email, phone, address })
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ company: data }, 201);
    }

    if (request.method === "PUT") {
      const body = await parseBody(request);
      const { id, ...updates } = body;
      if (!id) return apiError("id is required");

      const { data, error } = await serviceClient
        .from("companies")
        .update(updates)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      return apiJson({ company: data });
    }

    if (request.method === "DELETE") {
      const body = await parseBody(request);
      const id = body.id as string | undefined;
      if (!id) return apiError("id is required");

      await deleteCompanyRecord(serviceClient, id);
      return apiJson({ success: true });
    }

    return apiError("Method not allowed", 405);
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function resolveCompanyIdForAdmin(
  serviceClient: ReturnType<typeof getServiceClient>,
  userId: string,
  profile: Record<string, unknown>
): Promise<string | null> {
  if (profile.company_id) return profile.company_id as string;

  const { data: link } = await serviceClient
    .from("company_admins")
    .select("company_id")
    .eq("user_id", userId)
    .maybeSingle();

  return (link?.company_id as string | undefined) ?? null;
}

async function handleCompanyDashboardStats(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["company_admin"]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  try {
    const serviceClient = getServiceClient();
    const companyId = await resolveCompanyIdForAdmin(
      serviceClient,
      auth.user.id,
      profile as Record<string, unknown>
    );
    if (!companyId) return apiError("No company assigned to this admin", 403);

    const [bookings, providers, services, pending] = await Promise.all([
      serviceClient
        .from("bookings")
        .select("id", { count: "exact", head: true })
        .eq("company_id", companyId),
      serviceClient
        .from("providers")
        .select("id", { count: "exact", head: true })
        .eq("company_id", companyId)
        .eq("status", "approved"),
      serviceClient
        .from("services")
        .select("id", { count: "exact", head: true })
        .eq("company_id", companyId)
        .eq("is_active", true),
      serviceClient
        .from("bookings")
        .select("id", { count: "exact", head: true })
        .eq("company_id", companyId)
        .eq("status", "pending"),
    ]);

    return apiJson({
      stats: {
        bookings: bookings.count ?? 0,
        providers: providers.count ?? 0,
        services: services.count ?? 0,
        pending: pending.count ?? 0,
      },
    });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleCompanyCustomersList(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["super_admin", "company_admin"]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  try {
    const serviceClient = getServiceClient();
    const companyId =
      profile.role === "company_admin"
        ? (profile.company_id as string)
        : request.nextUrl.searchParams.get("company_id");

    if (!companyId) return apiJson({ customers: [] });

    const { data: bookings, error: bookingsError } = await serviceClient
      .from("bookings")
      .select("customer_id")
      .eq("company_id", companyId);
    if (bookingsError) throw new Error(bookingsError.message);

    const customerIds = [
      ...new Set((bookings ?? []).map((booking) => booking.customer_id as string)),
    ];
    if (customerIds.length === 0) return apiJson({ customers: [] });

    const { data: customers, error } = await serviceClient
      .from("customers")
      .select("id, user_id, default_address, profiles!customers_user_id_fkey(full_name, phone)")
      .in("id", customerIds);
    if (error) throw new Error(error.message);

    const enriched = await Promise.all(
      (customers ?? []).map(async (customer) => {
        const profileRow = customer.profiles as Record<string, unknown> | null;
        const { data: userData } = await serviceClient.auth.admin.getUserById(
          customer.user_id as string
        );
        return {
          ...customer,
          profiles: {
            ...(profileRow ?? {}),
            email: userData.user?.email ?? null,
          },
        };
      })
    );

    return apiJson({ customers: enriched });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function assertBookingAccess(
  serviceClient: ReturnType<typeof getServiceClient>,
  auth: NonNullable<Awaited<ReturnType<typeof getAuthFromRequest>>>,
  profile: Record<string, unknown>,
  bookingId: string
) {
  const { data: booking, error } = await serviceClient
    .from("bookings")
    .select("id, customer_id, provider_id, company_id, status")
    .eq("id", bookingId)
    .single();

  if (error || !booking) {
    return { response: apiError("Booking not found", 404) } as const;
  }

  const role = profile.role as string;

  if (role === "super_admin") {
    return { booking } as const;
  }

  if (role === "company_admin") {
    if (booking.company_id === profile.company_id) {
      return { booking } as const;
    }
    return { response: apiError("Forbidden", 403) } as const;
  }

  if (role === "customer") {
    const { data: customer } = await serviceClient
      .from("customers")
      .select("id")
      .eq("user_id", auth.user.id)
      .single();
    if (customer && booking.customer_id === customer.id) {
      return { booking } as const;
    }
    return { response: apiError("Forbidden", 403) } as const;
  }

  if (role === "provider") {
    const { data: provider } = await serviceClient
      .from("providers")
      .select("id")
      .eq("user_id", auth.user.id)
      .single();
    if (provider && booking.provider_id === provider.id) {
      return { booking } as const;
    }
    return { response: apiError("Forbidden", 403) } as const;
  }

  return { response: apiError("Forbidden", 403) } as const;
}

async function assertChatRoomAccess(
  serviceClient: ReturnType<typeof getServiceClient>,
  auth: NonNullable<Awaited<ReturnType<typeof getAuthFromRequest>>>,
  profile: Record<string, unknown>,
  chatRoomId: string
) {
  const { data: room, error } = await serviceClient
    .from("chat_rooms")
    .select("id, booking_id")
    .eq("id", chatRoomId)
    .single();

  if (error || !room) {
    return { response: apiError("Chat room not found", 404) } as const;
  }

  const access = await assertBookingAccess(
    serviceClient,
    auth,
    profile,
    room.booking_id as string
  );
  if ("response" in access) return access;
  return { room, booking: access.booking } as const;
}

async function handleCatalogCategories(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, [
    "super_admin",
    "company_admin",
    "customer",
    "provider",
  ]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    let query = serviceClient
      .from("categories")
      .select("*")
      .eq("is_active", true)
      .order("sort_order");

    if (profile.role === "company_admin" && profile.company_id) {
      query = query.eq("company_id", profile.company_id as string);
    }

    const { data, error } = await query;
    if (error) throw new Error(error.message);
    return apiJson({ categories: data ?? [] });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleChatMessagesList(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, [
    "super_admin",
    "company_admin",
    "customer",
    "provider",
  ]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    const chatRoomId = request.nextUrl.searchParams.get("chat_room_id");
    if (!chatRoomId) return apiError("chat_room_id is required");

    const access = await assertChatRoomAccess(
      serviceClient,
      auth,
      profile,
      chatRoomId
    );
    if ("response" in access) return access.response;

    const limit = Math.min(
      100,
      Math.max(1, parseInt(request.nextUrl.searchParams.get("limit") ?? "30", 10))
    );
    const before = request.nextUrl.searchParams.get("before");
    const after = request.nextUrl.searchParams.get("after");

    let query = serviceClient
      .from("messages")
      .select("*, profiles(full_name)")
      .eq("chat_room_id", chatRoomId);

    let rows: Record<string, unknown>[];
    if (before) {
      const { data, error } = await query
        .lt("created_at", before)
        .order("created_at", { ascending: false })
        .limit(limit + 1);
      if (error) throw new Error(error.message);
      rows = data ?? [];
    } else if (after) {
      const { data, error } = await query
        .gt("created_at", after)
        .order("created_at", { ascending: true })
        .limit(limit + 1);
      if (error) throw new Error(error.message);
      rows = data ?? [];
    } else {
      const { data, error } = await query
        .order("created_at", { ascending: false })
        .limit(limit + 1);
      if (error) throw new Error(error.message);
      rows = data ?? [];
    }

    const hasMore = rows.length > limit;
    const messages = hasMore ? rows.slice(0, limit) : rows;

    if (before || !after) {
      messages.reverse();
    }

    return apiJson({ messages, has_more: hasMore });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleChatRoomByBooking(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, [
    "super_admin",
    "company_admin",
    "customer",
    "provider",
  ]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    const bookingId = request.nextUrl.searchParams.get("booking_id");
    if (!bookingId) return apiError("booking_id is required");

    const access = await assertBookingAccess(
      serviceClient,
      auth,
      profile,
      bookingId
    );
    if ("response" in access) return access.response;

    const { data, error } = await serviceClient
      .from("chat_rooms")
      .select("id")
      .eq("booking_id", bookingId)
      .maybeSingle();
    if (error) throw new Error(error.message);

    return apiJson({ chat_room_id: data?.id ?? null });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleProfileUpdate(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "PUT") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["customer", "provider"]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  if (profile.role === "provider") {
    return apiError("Provider profiles are updated by your company admin.", 403);
  }

  const serviceClient = getServiceClient();

  try {
    const body = await parseBody(request);
    const full_name = body.full_name as string | undefined;
    const phone = body.phone as string | undefined;
    const default_address = body.default_address as string | undefined;

    if (full_name !== undefined || phone !== undefined) {
      const profileUpdates: Record<string, unknown> = {};
      if (full_name !== undefined) profileUpdates.full_name = full_name;
      if (phone !== undefined) profileUpdates.phone = phone;

      const { error: profileError } = await serviceClient
        .from("profiles")
        .update(profileUpdates)
        .eq("id", auth.user.id);
      if (profileError) throw new Error(profileError.message);
    }

    if (default_address !== undefined) {
      const { error: customerError } = await serviceClient
        .from("customers")
        .update({ default_address })
        .eq("user_id", auth.user.id);
      if (customerError) throw new Error(customerError.message);
    }

    return apiJson({ success: true });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleProfileProvider(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["provider"]);
  if ("response" in roleResult) return roleResult.response;

  const serviceClient = getServiceClient();

  try {
    const { data, error } = await serviceClient
      .from("providers")
      .select("id")
      .eq("user_id", auth.user.id)
      .maybeSingle();
    if (error) throw new Error(error.message);

    return apiJson({ provider_id: data?.id ?? null });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handleChatInbox(request: NextRequest): Promise<NextResponse> {
  if (request.method !== "GET") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, [
    "super_admin",
    "company_admin",
    "customer",
    "provider",
  ]);
  if ("response" in roleResult) return roleResult.response;
  const { profile } = roleResult;

  const serviceClient = getServiceClient();

  try {
    let bookingsQuery = serviceClient
      .from("bookings")
      .select("id, services(name)")
      .in("status", ["accepted", "in_progress", "completed"])
      .order("updated_at", { ascending: false });

    if (profile.role === "company_admin") {
      bookingsQuery = bookingsQuery.eq("company_id", profile.company_id as string);
    } else if (profile.role === "customer") {
      const { data: customer } = await serviceClient
        .from("customers")
        .select("id")
        .eq("user_id", auth.user.id)
        .single();
      if (!customer) return apiJson({ chats: [] });
      bookingsQuery = bookingsQuery.eq("customer_id", customer.id);
    } else if (profile.role === "provider") {
      const { data: provider } = await serviceClient
        .from("providers")
        .select("id")
        .eq("user_id", auth.user.id)
        .single();
      if (!provider) return apiJson({ chats: [] });
      bookingsQuery = bookingsQuery.eq("provider_id", provider.id);
    }

    const { data: bookings, error: bookingsError } = await bookingsQuery;
    if (bookingsError) throw new Error(bookingsError.message);

    type BookingRow = {
      id: string;
      services: { name: string } | null;
    };

    const rows = (bookings ?? []) as BookingRow[];
    if (rows.length === 0) {
      return apiJson({ chats: [] });
    }

    const bookingIds = rows.map((row) => row.id);
    const serviceNameByBooking = new Map(
      rows.map((row) => [row.id, row.services?.name ?? ""])
    );

    const { data: chatRooms, error: roomsError } = await serviceClient
      .from("chat_rooms")
      .select("id, booking_id")
      .in("booking_id", bookingIds);
    if (roomsError) throw new Error(roomsError.message);

    const roomMeta = (chatRooms ?? []).map((room) => ({
      bookingId: room.booking_id as string,
      chatRoomId: room.id as string,
      serviceName: serviceNameByBooking.get(room.booking_id as string) ?? "",
    }));

    if (roomMeta.length === 0) {
      return apiJson({ chats: [] });
    }

    const roomIds = roomMeta.map((r) => r.chatRoomId);

    const { data: unreadRows, error: unreadError } = await serviceClient
      .from("messages")
      .select("chat_room_id")
      .in("chat_room_id", roomIds)
      .is("read_at", null)
      .neq("sender_id", auth.user.id);
    if (unreadError) throw new Error(unreadError.message);

    const unreadByRoom = new Map<string, number>();
    for (const row of unreadRows ?? []) {
      const roomId = row.chat_room_id as string;
      unreadByRoom.set(roomId, (unreadByRoom.get(roomId) ?? 0) + 1);
    }

    const latestByRoom = new Map<
      string,
      { content: string; created_at: string }
    >();

    await Promise.all(
      roomIds.map(async (roomId) => {
        const { data, error } = await serviceClient
          .from("messages")
          .select("content, created_at")
          .eq("chat_room_id", roomId)
          .order("created_at", { ascending: false })
          .limit(1)
          .maybeSingle();
        if (!error && data) {
          latestByRoom.set(roomId, data as { content: string; created_at: string });
        }
      })
    );

    const chats = roomMeta
      .map((meta) => {
        const latest = latestByRoom.get(meta.chatRoomId);
        return {
          booking_id: meta.bookingId,
          chat_room_id: meta.chatRoomId,
          service_name: meta.serviceName,
          last_message: latest?.content ?? null,
          last_message_at: latest?.created_at ?? null,
          unread_count: unreadByRoom.get(meta.chatRoomId) ?? 0,
        };
      })
      .sort((a, b) => {
        const aTime = a.last_message_at
          ? new Date(a.last_message_at).getTime()
          : 0;
        const bTime = b.last_message_at
          ? new Date(b.last_message_at).getTime()
          : 0;
        return bTime - aTime;
      });

    return apiJson({ chats });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handlePushRegisterToken(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "POST") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  const roleResult = await withRole(auth, ["customer", "provider"]);
  if ("response" in roleResult) return roleResult.response;

  try {
    const body = await parseBody(request);
    const token = (body.token as string | undefined)?.trim();
    const platform = (body.platform as string | undefined)?.trim();

    if (!token) return apiError("token is required", 400);
    if (!platform || !["ios", "android", "web"].includes(platform)) {
      return apiError("platform must be ios, android, or web", 400);
    }

    const serviceClient = getServiceClient();
    const { error } = await serviceClient.from("device_tokens").upsert(
      {
        user_id: auth.user.id,
        token,
        platform,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "user_id,token" }
    );

    if (error) throw new Error(error.message);
    return apiJson({ ok: true });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

async function handlePushUnregisterToken(
  request: NextRequest
): Promise<NextResponse> {
  if (request.method !== "DELETE") return apiError("Method not allowed", 405);

  const authResult = await requireAuth(request);
  if ("response" in authResult) return authResult.response;
  const { auth } = authResult;

  try {
    const body = await parseBody(request);
    const token = (body.token as string | undefined)?.trim();

    const serviceClient = getServiceClient();
    let query = serviceClient
      .from("device_tokens")
      .delete()
      .eq("user_id", auth.user.id);

    if (token) {
      query = query.eq("token", token);
    }

    const { error } = await query;
    if (error) throw new Error(error.message);
    return apiJson({ ok: true });
  } catch (e) {
    return apiError((e as Error).message, 500);
  }
}

const HANDLERS: Record<string, Handler> = {
  "auth-sign-in": handleAuthSignIn,
  "auth-register-customer": handleAuthRegisterCustomer,
  "auth-forgot-password": handleAuthForgotPassword,
  "auth-me": handleAuthMe,
  "auth-register-provider": handleAuthRegisterProvider,
  "auth-register-company-admin": handleAuthRegisterCompanyAdmin,
  "bookings-list": handleBookingsList,
  "bookings-create": handleBookingsCreate,
  "bookings-assign": handleBookingsAssign,
  "bookings-update-status": handleBookingsUpdateStatus,
  "bookings-cancel": handleBookingsCancel,
  "reviews-submit": handleReviewsSubmit,
  "chat-send-message": handleChatSendMessage,
  "chat-mark-read": handleChatMarkRead,
  "chat-messages-list": handleChatMessagesList,
  "chat-room-by-booking": handleChatRoomByBooking,
  "chat-inbox": handleChatInbox,
  "catalog-categories": handleCatalogCategories,
  "profile-update": handleProfileUpdate,
  "profile-provider": handleProfileProvider,
  "push-register-token": handlePushRegisterToken,
  "push-unregister-token": handlePushUnregisterToken,
  "company-providers-manage": handleCompanyProvidersManage,
  "company-services-crud": handleCompanyServicesCrud,
  "company-categories-crud": handleCompanyCategoriesCrud,
  "company-customers-list": handleCompanyCustomersList,
  "company-dashboard-stats": handleCompanyDashboardStats,
  "platform-settings": handlePlatformSettingsPublic,
  "admin-platform-settings": handleAdminPlatformSettings,
  "admin-companies-crud": handleAdminCompaniesCrud,
};

export async function dispatchApi(
  request: NextRequest,
  name: string
): Promise<NextResponse> {
  const handler = HANDLERS[name];
  if (!handler) {
    return apiError("Not found", 404);
  }
  return handler(request);
}
