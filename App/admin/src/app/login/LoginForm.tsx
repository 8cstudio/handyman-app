"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Button, Input, Card, ErrorAlert } from "@handyman/shared";

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [mode, setMode] = useState<"login" | "forgot">("login");

  useEffect(() => {
    if (searchParams.get("error") === "unauthorized") {
      setError("You do not have access to this panel.");
    }
  }, [searchParams]);

  async function handleForgotPassword(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");
    setMessage("");

    try {
      const response = await fetch("/api/auth/forgot-password", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
      const result = (await response.json()) as { ok: boolean; message?: string };
      if (!response.ok || !result.ok) {
        setError(result.message ?? "Could not send reset email.");
      } else {
        setMessage(result.message ?? "Check your email for reset instructions.");
      }
    } catch {
      setError("Can't reach the server. Check your internet connection and try again.");
    }
    setLoading(false);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const result = (await response.json()) as {
        ok: boolean;
        message?: string;
        redirectTo?: string;
      };

      if (!response.ok || !result.ok) {
        setError(result.message ?? "Sign-in failed. Please try again.");
        setLoading(false);
        return;
      }

      router.push(result.redirectTo ?? "/");
      router.refresh();
    } catch {
      setError("Can't reach the server. Check your internet connection and try again.");
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <Card title="Admin Login" className="w-full max-w-md !p-8">
        <p className="mb-4 text-sm text-[var(--color-text-secondary)]">
          {mode === "login"
            ? "Sign in as Super Admin or Company Admin. You will be routed to the correct dashboard."
            : "Enter your admin email and we will send password reset instructions."}
        </p>
        <form onSubmit={mode === "login" ? handleSubmit : handleForgotPassword} className="space-y-4">
          <Input
            label="Email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          {mode === "login" && (
            <Input
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          )}
          {error && <ErrorAlert message={error} />}
          {message && <p className="text-sm text-green-600">{message}</p>}
          <Button type="submit" className="w-full" disabled={loading}>
            {loading
              ? mode === "login"
                ? "Signing in..."
                : "Sending..."
              : mode === "login"
                ? "Sign In"
                : "Send reset link"}
          </Button>
          <button
            type="button"
            className="w-full text-sm text-[var(--color-text-secondary)] hover:underline"
            onClick={() => {
              setMode(mode === "login" ? "forgot" : "login");
              setError("");
              setMessage("");
            }}
          >
            {mode === "login" ? "Forgot password?" : "Back to sign in"}
          </button>
        </form>
      </Card>
    </div>
  );
}
