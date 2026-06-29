import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { logServer } from "@/lib/server-logger";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const email = typeof body.email === "string" ? body.email.trim() : "";

    if (!email) {
      return NextResponse.json(
        { ok: false, message: "Please enter your email address." },
        { status: 400 }
      );
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

    const redirectTo =
      typeof body.redirect_to === "string" && body.redirect_to.length > 0
        ? body.redirect_to
        : `${request.headers.get("origin") ?? "http://localhost:3000"}/login`;

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo,
    });

    if (error) {
      logServer({
        level: "warn",
        context: "auth/forgot-password",
        message: "Password reset request failed",
        detail: error.message,
        meta: { email },
      });
      return NextResponse.json({ ok: false, message: error.message }, { status: 400 });
    }

    logServer({
      level: "info",
      context: "auth/forgot-password",
      message: "Password reset email requested",
      meta: { email },
    });

    return NextResponse.json({
      ok: true,
      message:
        "If an account exists for this email, password reset instructions have been sent.",
    });
  } catch (error) {
    logServer({
      context: "auth/forgot-password",
      message: "Unexpected forgot-password error",
      detail: error instanceof Error ? error.message : "Unknown error",
    });
    return NextResponse.json(
      { ok: false, message: "Could not process password reset request." },
      { status: 500 }
    );
  }
}
