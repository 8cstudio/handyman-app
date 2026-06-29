export type AdminRole = "super_admin" | "company_admin";

export function dashboardPathForRole(role: string | undefined | null): string | null {
  if (role === "super_admin") return "/platform/dashboard";
  if (role === "company_admin") return "/company/dashboard";
  return null;
}

export function isPlatformRoute(pathname: string): boolean {
  return pathname.startsWith("/platform");
}

export function isCompanyRoute(pathname: string): boolean {
  return pathname.startsWith("/company");
}
