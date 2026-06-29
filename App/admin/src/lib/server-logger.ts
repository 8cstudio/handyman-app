export type ServerLogLevel = "info" | "warn" | "error";

export interface ServerLogPayload {
  level?: ServerLogLevel;
  context: string;
  message: string;
  detail?: string;
  meta?: Record<string, unknown>;
}

function timestamp(): string {
  return new Date().toISOString();
}

export function logServer(payload: ServerLogPayload): void {
  const level = (payload.level ?? "error").toUpperCase();
  const lines = [
    `[${timestamp()}] [${level}] [${payload.context}] ${payload.message}`,
  ];

  if (payload.detail) {
    lines.push(`  detail: ${payload.detail}`);
  }

  if (payload.meta && Object.keys(payload.meta).length > 0) {
    lines.push(`  meta: ${JSON.stringify(payload.meta)}`);
  }

  const output = lines.join("\n");

  if (payload.level === "info") {
    console.info(output);
    return;
  }

  if (payload.level === "warn") {
    console.warn(output);
    return;
  }

  console.error(output);
}
