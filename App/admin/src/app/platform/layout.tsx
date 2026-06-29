import { PlatformSidebar } from "@/components/PlatformSidebar";
import { AdminErrorProvider } from "@/components/AdminErrorProvider";
import { GlassShell } from "@/components/GlassShell";

export default function PlatformLayout({ children }: { children: React.ReactNode }) {
  return (
    <GlassShell>
      <div className="flex min-h-screen">
        <PlatformSidebar />
        <main className="flex-1 overflow-auto p-6 md:p-8">
          <AdminErrorProvider>{children}</AdminErrorProvider>
        </main>
      </div>
    </GlassShell>
  );
}
