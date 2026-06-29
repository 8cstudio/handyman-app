import type { NextRequest } from "next/server";
import { apiOptions } from "@/lib/server/api-response";
import { dispatchApi } from "@/lib/server/dispatch";

type RouteContext = { params: Promise<{ name: string }> | { name: string } };

async function resolveName(params: RouteContext["params"]) {
  return "then" in params ? (await params).name : params.name;
}

async function handle(request: NextRequest, context: RouteContext) {
  const name = await resolveName(context.params);
  return dispatchApi(request, name);
}

export async function OPTIONS() {
  return apiOptions();
}

export async function GET(request: NextRequest, context: RouteContext) {
  return handle(request, context);
}

export async function POST(request: NextRequest, context: RouteContext) {
  return handle(request, context);
}

export async function PUT(request: NextRequest, context: RouteContext) {
  return handle(request, context);
}

export async function DELETE(request: NextRequest, context: RouteContext) {
  return handle(request, context);
}
