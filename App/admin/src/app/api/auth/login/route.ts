import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { dashboardPathForRole } from "@/lib/auth-routes";
import { logServer } from "@/lib/server-logger";
import {
  formatAuthError,
  formatProfileError,
  formatRoleError,
} from "@handyman/shared";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";

    if (!email || !password) {
      const message = "Please enter both email and password.";
      logServer({
        level: "warn",
        context: "auth/login",
        message,
        meta: { email: email || "(empty)" },
      });
      return NextResponse.json({ ok: false, message }, { status: 400 });
    }

    const cookieStore = await cookies();
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return cookieStore.getAll();
          },
          setAll(cookiesToSet) {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          },
        },
      }
    );

    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) {
      const message = formatAuthError(authError.message);
      logServer({
        level: "warn",
        context: "auth/login",
        message,
        detail: authError.message,
        meta: { email },
      });
      return NextResponse.json({ ok: false, message }, { status: 401 });
    }

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", authData.user.id)
      .single();

    if (profileError) {
      const message = formatProfileError(profileError.message);
      await supabase.auth.signOut();
      logServer({
        context: "auth/login",
        message,
        detail: profileError.message,
        meta: { email, userId: authData.user.id },
      });
      return NextResponse.json({ ok: false, message }, { status: 403 });
    }

    const redirectTo = dashboardPathForRole(profile?.role);
    if (!redirectTo) {
      const message = formatRoleError(profile?.role);
      await supabase.auth.signOut();
      logServer({
        level: "warn",
        context: "auth/login",
        message,
        meta: { email, role: profile?.role ?? "none" },
      });
      return NextResponse.json({ ok: false, message }, { status: 403 });
    }

    logServer({
      level: "info",
      context: "auth/login",
      message: "Admin signed in successfully",
      meta: { email, role: profile.role, redirectTo },
    });

    return NextResponse.json({ ok: true, redirectTo });
  } catch (error) {
    const detail = error instanceof Error ? error.message : "Unknown error";
    const message = "Sign-in failed unexpectedly. Please try again.";
    logServer({
      context: "auth/login",
      message,
      detail,
    });
    return NextResponse.json({ ok: false, message }, { status: 500 });
  }
}
