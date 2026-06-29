# Handyman SaaS Platform — Deployment Guide

## Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) or Supabase cloud project
- Node.js 18+
- Flutter SDK 3.2+
- Vercel account (for web admin panel)

## 1. Supabase Backend

```bash
cd App/supabase
supabase start          # local development
supabase db reset       # apply migrations + seed
supabase functions serve # run Edge Functions locally
```

Copy your local keys from `supabase status` into env files (or use Supabase cloud dashboard).

### Production

```bash
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase functions deploy
```

## 2. Environment Variables

### App/admin/.env.local

```
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### flutter-bloc-boilerplate/.env

```
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your-anon-key
USE_MOCK_AUTH=false
```

## 3. Admin Panel (Super Admin + Company Admin)

```bash
cd App/shared && npm install
cd ../admin && npm install
cp .env.example .env.local   # fill in Supabase keys
npm run dev                    # http://localhost:3000/login
```

Deploy to Vercel:

```bash
vercel --cwd App/admin
```

## 4. Flutter Mobile App

```bash
cd flutter-bloc-boilerplate
cp .env.example .env
flutter pub get
flutter run
```

## 5. Initial Setup (First Run)

1. Apply migrations and seed data
2. Create Super Admin user via Supabase dashboard or SQL:
   - Create auth user, then insert profile with `role = 'super_admin'`
3. Log into admin panel → create company → create company admin via edge function
4. Register as Provider/Customer in mobile app

## 6. End-to-End Workflow Test

1. **Super Admin**: Create company, set theme colors
2. **Company Admin**: Add categories/services, approve providers
3. **Customer (mobile)**: Browse → book service
4. **Company Admin**: Assign provider to booking
5. **Provider (mobile)**: Accept → start → complete job
6. **Customer**: Chat with provider → submit review
7. **Verify**: Theme changes in Super Admin appear in all apps

## Project Structure

```
App/
├── supabase/          # DB, RLS, Edge Functions
├── shared/            # Shared TS types + UI
└── admin/             # Next.js admin (Super + Company Admin, port 3000)

flutter-bloc-boilerplate/  # Single mobile app (Customer + Provider)
```

## Edge Functions

| Function | Purpose |
|----------|---------|
| auth-register-customer | Customer signup |
| auth-register-provider | Provider signup |
| auth-register-company-admin | Create company admin |
| admin-companies-crud | Company management |
| admin-platform-settings | Global theme |
| company-categories-crud | Categories |
| company-services-crud | Services |
| company-providers-manage | Provider approval/docs |
| bookings-create | Customer booking |
| bookings-assign | Assign provider |
| bookings-update-status | Status transitions |
| bookings-cancel | Cancel booking |
| bookings-list | List bookings |
| chat-send-message | Send chat message |
| chat-mark-read | Read receipts |
| reviews-submit | Customer review |
