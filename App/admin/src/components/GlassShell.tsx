import { ReactNode } from "react";

export function GlassShell({ children }: { children: ReactNode }) {
  return (
    <div className="admin-shell">
      <div className="liquid-bg" aria-hidden="true">
        <div className="liquid-blob liquid-blob-1" />
        <div className="liquid-blob liquid-blob-2" />
        <div className="liquid-blob liquid-blob-3" />
      </div>
      <div className="relative z-10">{children}</div>
    </div>
  );
}
