import { Card } from "@handyman/shared";
import { GlassShell } from "@/components/GlassShell";

export default function SetupPage() {
  return (
    <GlassShell>
      <div className="flex min-h-screen items-center justify-center p-4">
        <Card title="Supabase not configured" className="max-w-lg">
          <p className="mb-4 text-sm text-[var(--color-text-secondary)]">
            Add your Supabase project credentials to{" "}
            <code className="glass-panel rounded px-1.5 py-0.5 text-xs">App/admin/.env.local</code>, then restart{" "}
            <code className="glass-panel rounded px-1.5 py-0.5 text-xs">npm run dev</code>.
          </p>
          <pre className="glass-panel mb-4 overflow-x-auto rounded-xl p-4 text-xs text-[var(--color-success)]">
{`NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key`}
          </pre>
          <p className="text-sm text-[var(--color-text-secondary)]">
            Get these from{" "}
            <a
              href="https://supabase.com/dashboard/project/_/settings/api"
              className="text-[var(--color-primary)] underline"
              target="_blank"
              rel="noreferrer"
            >
              Supabase Dashboard → Settings → API
            </a>
            .
          </p>
        </Card>
      </div>
    </GlassShell>
  );
}
