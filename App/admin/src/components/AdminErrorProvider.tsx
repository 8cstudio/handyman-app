"use client";

import { useEffect, useState } from "react";
import { ErrorAlert, registerGlobalErrorHandler } from "@handyman/shared";

export function AdminErrorProvider({ children }: { children: React.ReactNode }) {
  const [error, setError] = useState<{ message: string; detail?: string } | null>(null);

  useEffect(() => {
    registerGlobalErrorHandler((message, detail) => {
      setError({ message, detail });
    });

    return () => registerGlobalErrorHandler(null);
  }, []);

  return (
    <>
      {error && (
        <div className="mb-6">
          <ErrorAlert
            message={error.message}
            detail={error.detail}
            onDismiss={() => setError(null)}
          />
        </div>
      )}
      {children}
    </>
  );
}
