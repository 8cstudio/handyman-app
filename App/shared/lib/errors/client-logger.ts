import { formatApiError } from "./format-error";

export type ClientLogLevel = "info" | "warn" | "error";

export interface ClientLogPayload {
  level?: ClientLogLevel;
  context: string;
  message: string;
  detail?: string;
  meta?: Record<string, unknown>;
}

type GlobalErrorHandler = (message: string, detail?: string) => void;

let globalErrorHandler: GlobalErrorHandler | null = null;

export function registerGlobalErrorHandler(handler: GlobalErrorHandler | null): void {
  globalErrorHandler = handler;
}

function logToBrowser(payload: ClientLogPayload): void {
  const level = payload.level ?? "error";
  const prefix = `[${payload.context}] ${payload.message}`;
  const detail = payload.detail ? `\n  detail: ${payload.detail}` : "";

  if (level === "info") {
    console.info(prefix + detail, payload.meta ?? "");
    return;
  }

  if (level === "warn") {
    console.warn(prefix + detail, payload.meta ?? "");
    return;
  }

  console.error(prefix + detail, payload.meta ?? "");
}

function sendToServer(payload: ClientLogPayload): void {
  if (typeof window === "undefined") return;

  void fetch("/api/log", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      level: payload.level ?? "error",
      context: payload.context,
      message: payload.message,
      detail: payload.detail,
      meta: payload.meta,
      path: window.location.pathname,
    }),
    keepalive: true,
  }).catch(() => {
    // Avoid recursive logging if the log endpoint is unavailable.
  });
}

export function logClientEvent(payload: ClientLogPayload): void {
  logToBrowser(payload);

  if ((payload.level ?? "error") === "error") {
    globalErrorHandler?.(payload.message, payload.detail);
  }

  sendToServer(payload);
}

export function logClientError(
  context: string,
  rawError: unknown,
  meta?: Record<string, unknown>
): string {
  const detail =
    rawError instanceof Error
      ? rawError.message
      : typeof rawError === "string"
        ? rawError
        : "Unknown error";

  const message = formatApiError(detail);

  logClientEvent({
    level: "error",
    context,
    message,
    detail,
    meta,
  });

  return message;
}
