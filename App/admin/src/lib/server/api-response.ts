import { NextResponse } from "next/server";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Authorization, Content-Type",
};

export function apiJson(data: unknown, status = 200) {
  return NextResponse.json(data, { status, headers: corsHeaders });
}

export function apiError(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status, headers: corsHeaders });
}

export function apiOptions() {
  return new NextResponse(null, { status: 204, headers: corsHeaders });
}
