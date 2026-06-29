import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import {
  dashboardPathForRole,
  isCompanyRoute,
  isPlatformRoute,
} from "@/lib/auth-routes";
import { isSupabaseConfigured } from "@/lib/supabase-config";
import { logServer } from "@/lib/server-logger";

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (pathname.startsWith("/api/")) {
    return NextResponse.next();
  }

  if (pathname === "/setup") {
    return NextResponse.next();
  }

  if (!isSupabaseConfigured()) {
    return NextResponse.redirect(new URL("/setup", request.url));
  }

  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const isLoginPage = pathname === "/login";
  const isProtected =
    isPlatformRoute(pathname) || isCompanyRoute(pathname) || pathname === "/";

  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    if (isLoginPage) return response;
    if (isProtected) {
      logServer({
        level: "warn",
        context: "middleware/auth",
        message: "Redirected unauthenticated user to login",
        meta: { pathname },
      });
      return NextResponse.redirect(new URL("/login", request.url));
    }
    return response;
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  const role = profile?.role;
  const dashboard = dashboardPathForRole(role);

  if (isLoginPage || pathname === "/") {
    if (dashboard) {
      return NextResponse.redirect(new URL(dashboard, request.url));
    }
    await supabase.auth.signOut();
    logServer({
      level: "warn",
      context: "middleware/auth",
      message: "Signed out user without admin role",
      meta: { pathname, role: role ?? "none", userId: user.id },
    });
    return NextResponse.redirect(new URL("/login?error=unauthorized", request.url));
  }

  if (isPlatformRoute(pathname) && role !== "super_admin") {
    await supabase.auth.signOut();
    logServer({
      level: "warn",
      context: "middleware/auth",
      message: "Blocked non-super-admin from platform route",
      meta: { pathname, role: role ?? "none", userId: user.id },
    });
    return NextResponse.redirect(new URL("/login?error=unauthorized", request.url));
  }

  if (isCompanyRoute(pathname) && role !== "company_admin") {
    await supabase.auth.signOut();
    logServer({
      level: "warn",
      context: "middleware/auth",
      message: "Blocked non-company-admin from company route",
      meta: { pathname, role: role ?? "none", userId: user.id },
    });
    return NextResponse.redirect(new URL("/login?error=unauthorized", request.url));
  }

  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
