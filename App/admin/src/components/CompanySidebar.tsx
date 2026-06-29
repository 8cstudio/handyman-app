"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient, useTheme, Button } from "@handyman/shared";

const links = [
  { href: "/company/dashboard", label: "Dashboard" },
  { href: "/company/categories", label: "Categories" },
  { href: "/company/services", label: "Services" },
  { href: "/company/providers", label: "Providers" },
  { href: "/company/customers", label: "Customers" },
  { href: "/company/bookings", label: "Bookings" },
  { href: "/company/chat", label: "Chat" },
  { href: "/company/profile", label: "Company Profile" },
];

export function CompanySidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { platformName, isDark, setIsDark } = useTheme();

  async function handleSignOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
  }

  return (
    <aside className="glass-sidebar flex h-screen w-64 flex-col">
      <div className="border-b border-[var(--glass-border)] p-5">
        <h1 className="text-lg font-bold tracking-tight text-[var(--color-text)]">{platformName}</h1>
        <p className="text-xs text-[var(--color-text-secondary)]">Company Admin</p>
      </div>
      <nav className="flex-1 space-y-1.5 overflow-y-auto p-4">
        {links.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className={
              pathname === link.href ? "glass-nav-link-active" : "glass-nav-link-inactive"
            }
          >
            {link.label}
          </Link>
        ))}
      </nav>
      <div className="space-y-2 border-t border-[var(--glass-border)] p-4">
        <button
          onClick={() => setIsDark(!isDark)}
          className="glass-nav-link-inactive w-full text-left"
        >
          {isDark ? "Light Mode" : "Dark Mode"}
        </button>
        <Button variant="ghost" className="w-full" onClick={handleSignOut}>
          Sign Out
        </Button>
      </div>
    </aside>
  );
}
