import { NextResponse } from "next/server";
import { logServer } from "@/lib/server-logger";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const level = body.level === "info" || body.level === "warn" ? body.level : "error";

    logServer({
      level,
      context: typeof body.context === "string" ? body.context : "client",
      message: typeof body.message === "string" ? body.message : "Unknown client error",
      detail: typeof body.detail === "string" ? body.detail : undefined,
      meta: {
        path: typeof body.path === "string" ? body.path : undefined,
        ...(body.meta && typeof body.meta === "object" ? body.meta : {}),
      },
    });

    return NextResponse.json({ ok: true });
  } catch (error) {
    logServer({
      context: "api/log",
      message: "Failed to process client log payload",
      detail: error instanceof Error ? error.message : "Unknown error",
    });
    return NextResponse.json({ ok: false }, { status: 400 });
  }
}
