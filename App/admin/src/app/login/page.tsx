import { Suspense } from "react";
import { LoginForm } from "./LoginForm";
import { GlassShell } from "@/components/GlassShell";

export default function LoginPage() {
  return (
    <GlassShell>
      <Suspense
        fallback={
          <div className="flex min-h-screen items-center justify-center">
            <div className="glass-panel rounded-2xl px-8 py-6 text-sm">Loading...</div>
          </div>
        }
      >
        <LoginForm />
      </Suspense>
    </GlassShell>
  );
}
