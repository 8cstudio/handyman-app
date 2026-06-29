# Handyman SaaS — Complete Guide

Multi-tenant handyman platform: **one admin web app** (Super Admin + Company Admin) and **one Flutter app** (Customer + Provider), backed by **Supabase** (Postgres, Auth, Storage, Realtime) and **Next.js API routes** (no Edge Functions).

| App | Who | URL / command |
|-----|-----|----------------|
| **Admin** | Super Admin, Company Admin | http://localhost:3000/login |
| **Flutter** | Customer, Provider | `flutter run` |
| **Backend** | Shared by all clients | Supabase cloud (or local CLI) |

Full product spec: [readme.txt](./readme.txt)

---

## Project layout

```
App/
├── admin/          # Next.js — Super + Company Admin (port 3000)
├── shared/         # Shared UI components + Supabase helpers
├── supabase/       # SQL migrations, seed (Edge Functions deprecated — use admin /api/v1)
├── README.md       # This file
├── DEPLOYMENT.md   # Production deploy notes
└── cursor.txt      # Quick copy/paste commands

flutter-bloc-boilerplate/   # Mobile app (repo root, sibling of App/)
```

**Do not run `npm install` inside `App/`** — there is no root `package.json`. Use `App/shared` and `App/admin`.

---

## Prerequisites

| Tool | Required for | Install |
|------|----------------|---------|
| **Node.js 18+** | Admin panel | [nodejs.org](https://nodejs.org) or `brew install node` |
| **Flutter SDK** | Mobile app | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| **Supabase CLI** | Full backend setup (optional*) | `brew install supabase/tap/supabase` |

\*You can apply migrations and deploy functions via the [Supabase Dashboard](https://supabase.com/dashboard) instead of the CLI.

---

## Choose how to run

### Option A — Flutter only (fastest, no Supabase)

Best for UI/demo. **No admin panel, no backend, no realtime.**

`flutter-bloc-boilerplate/.env`:

```env
USE_MOCK_AUTH=true
SUPABASE_URL=
SUPABASE_ANON_KEY=
```

```bash
cd flutter-bloc-boilerplate
flutter pub get
flutter run
```

**Demo logins** (any password):

| Email | Role |
|-------|------|
| `customer@demo.com` | Customer |
| `provider@demo.com` | Provider (approved) |
| `provider-pending@demo.com` | Provider (pending) |

More: [../flutter-bloc-boilerplate/MOCK_MODE.md](../flutter-bloc-boilerplate/MOCK_MODE.md)

---

### Option B — Full stack (admin + Flutter + live backend)

Requires Supabase project with **schema** and **users**. The **admin Next.js app** (`npm run dev`) serves all backend APIs at `/api/v1/*`. Enables login, bookings, chat, and **realtime** updates.

---

## Supabase connection

Use **one Supabase project** for admin + Flutter.

| App | Env file | Variables |
|-----|----------|-----------|
| Admin | `App/admin/.env.local` | `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
| Flutter | `flutter-bloc-boilerplate/.env` | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `USE_MOCK_AUTH` |

Get values from [Dashboard → Project Settings → API](https://supabase.com/dashboard/project/_/settings/api):

- **Project URL** → `*_SUPABASE_URL`
- **anon / publishable key** → `*_ANON_KEY` (supports `sb_publishable_...` keys)

**Never** commit or paste in docs:

- Database password (Postgres direct access only)
- `service_role` secret (server-only)

### Admin — `App/admin/.env.local`

```bash
cd App/admin
cp .env.example .env.local
```

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

### Flutter — backend mode

```env
USE_MOCK_AUTH=false
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

Restart after env changes: `npm run dev` (admin) or full **restart** of Flutter (not hot reload).

If admin env is missing → http://localhost:3000/setup

---

## Prepare Supabase (one-time, Option B)

### Method 1 — Supabase CLI (recommended)

```bash
cd App/supabase

supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push              # schema, RLS, realtime publication
```

Add to `App/admin/.env.local`:

```env
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_from_dashboard
```

Backend APIs run with the admin app — **no Edge Functions deploy needed**:

```bash
cd App/admin && npm run dev   # serves /api/v1/*
```

Optional demo data — run in Dashboard → **SQL Editor**:

```
App/supabase/seed.sql
```

(Creates demo company, categories, and services.)

### Method 2 — Dashboard only (no CLI)

1. **SQL Editor** — run each file in order:
   - `App/supabase/migrations/20240626000001_initial_schema.sql`
   - `App/supabase/migrations/20240626000002_rls_policies.sql`
   - `App/supabase/migrations/20240626000003_storage_buckets.sql`
   - `App/supabase/migrations/20240626000004_realtime_tables.sql`
   - `App/supabase/seed.sql` (optional)
2. Set env files (above). Backend logic is in `App/admin/src/lib/server/` — served at `/api/v1/*` when you run the admin app.

### Local Supabase (optional alternative to cloud)

```bash
cd App/supabase
supabase start
supabase db reset
supabase functions serve    # separate terminal
supabase status             # copy URL + anon key → env files
```

Local URL is usually `http://127.0.0.1:54321`.

---

## Create users (one-time, Option B)

### Super Admin
For Login:
Email: superadmin@handyman.local
Password: SuperAdmin123!
1. Dashboard → **Authentication** → Add user (email + password)
2. Copy user UUID
3. **SQL Editor**:

```sql
INSERT INTO profiles (id, role, full_name)
VALUES ('YOUR_USER_UUID', 'super_admin', 'Super Admin');
```

4. Log in at http://localhost:3000/login → routed to `/platform/dashboard`

### Company Admin

Created by Super Admin via Edge Function (requires Super Admin JWT):

```bash
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/auth-register-company-admin \
  -H "Authorization: Bearer YOUR_SUPER_ADMIN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@demo.com",
    "password": "password123",
    "full_name": "Company Admin",
    "company_id": "a0000000-0000-4000-8000-000000000001"
  }'
```

Use demo `company_id` from seed, or a company you created in the admin panel.

Company Admin login → routed to `/company/dashboard`.

### Customer / Provider (mobile)

Sign up in the Flutter app (`USE_MOCK_AUTH=false`). Providers start as **pending** — approve them in admin → **Providers**.

---

## Run admin panel

```bash
cd App/shared && npm install
cd ../admin && npm install
npm run dev
```

| URL | Purpose |
|-----|---------|
| http://localhost:3000/login | Shared login (Super + Company Admin) |
| http://localhost:3000/platform/* | Super Admin only |
| http://localhost:3000/company/* | Company Admin only |

Middleware routes by `profiles.role` after login (same idea as Customer vs Provider in Flutter).

---

## Run Flutter app

```bash
cd flutter-bloc-boilerplate
flutter pub get
flutter run
```

Set `USE_MOCK_AUTH=false` and Supabase keys for live backend (Option B).

---

## Realtime (Option B only)

Supabase Realtime auto-refreshes UI when data changes. **Mock mode has no realtime.**

| Client | Live updates |
|--------|----------------|
| Admin — dashboards, bookings, catalog, chat | Yes |
| Admin — companies list, customers, profile | Manual refresh only |
| Flutter — theme, bookings, catalog, chat | Yes |
| Flutter — mock mode | No |

**Smoke test:** assign a booking in admin → provider Orders tab in Flutter updates without pull-to-refresh.

---

## Backend API routes (Next.js — no Edge Functions)

All handlers live in `App/admin/src/lib/server/dispatch.ts` and are exposed at:

```
/api/v1/{handler-name}
```

Examples: `/api/v1/auth-sign-in`, `/api/v1/bookings-list`, `/api/v1/admin-companies-crud`

| Route name | Purpose |
|------------|---------|
| `auth-sign-in` | Mobile login (customer/provider) |
| `auth-register-customer` | Customer signup (Flutter) |
| `auth-register-provider` | Create provider (company admin only) |
| `auth-register-company-admin` | Create company admin |
| `auth-forgot-password` | Password reset email |
| `auth-me` | Current user profile |
| `admin-companies-crud` | Company management |
| `admin-platform-settings` | Global theme |
| `company-categories-crud` | Categories |
| `company-services-crud` | Services |
| `company-providers-manage` | Provider approval/docs |
| `bookings-create` | Customer booking |
| `bookings-assign` | Assign provider |
| `bookings-update-status` | Status transitions |
| `bookings-cancel` | Cancel booking |
| `bookings-list` | List bookings |
| `chat-send-message` | Send chat message |
| `chat-mark-read` | Read receipts |
| `reviews-submit` | Customer review |

Flutter `API_BASE_URL` must point at the admin API, e.g. `http://localhost:3000/api/v1` (use `http://10.0.2.2:3000/api/v1` on Android emulator).

---

## End-to-end workflow test

1. **Super Admin** — create company, set theme colors
2. **Company Admin** — add categories/services, approve provider
3. **Customer (Flutter)** — browse → book service
4. **Company Admin** — assign provider to booking
5. **Provider (Flutter)** — accept → start → complete
6. **Both** — chat (messages appear live)
7. **Customer** — submit review
8. **Super Admin** — theme change appears in admin + Flutter

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `npm error ENOENT` in `App/` | Run from `App/admin`, not `App/` |
| `/setup` page in admin | Fill `App/admin/.env.local`, restart `npm run dev` |
| `supabase: command not found` | `brew install supabase/tap/supabase` or use Dashboard method |
| Admin login fails | User in Auth + `profiles` row with correct `role` |
| API / function errors | `supabase functions deploy` |
| Empty tables / errors | `supabase db push` or run migrations in SQL Editor |
| Flutter still offline | Set `USE_MOCK_AUTH=false`, restart app |
| Realtime not working | Backend mode + migrations applied (realtime publication) |

---

## Production deploy

See [DEPLOYMENT.md](./DEPLOYMENT.md):

- Supabase: `supabase link`, `db push`, `functions deploy`
- Admin: Vercel (`App/admin`)
- Flutter: App Store / Play Store builds

---

## Quick command reference

**Flutter mock (no Supabase):**
```bash
cd flutter-bloc-boilerplate && flutter run
```

**Admin only:**
```bash
cd App/admin && npm run dev
```

**Full backend prep:**
```bash
cd App/supabase && supabase link --project-ref YOUR_REF && supabase db push && supabase functions deploy
```

Copy-paste checklist: [cursor.txt](./cursor.txt)
