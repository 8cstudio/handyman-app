# Mock Mode (Flutter App)

Set `USE_MOCK_AUTH=true` in `flutter-bloc-boilerplate/.env` to run the entire mobile app **without Supabase**. All features use in-memory mock data.

```env
USE_MOCK_AUTH=true
SUPABASE_URL=
SUPABASE_ANON_KEY=
```

## Demo accounts (any password)

| Email | Role | Notes |
|-------|------|-------|
| `customer@demo.com` | Customer | Has sample bookings + chat |
| `provider@demo.com` | Provider (approved) | Can accept/start/complete jobs |
| `provider-pending@demo.com` | Provider (pending) | Shows pending approval screen |

You can also **sign up** with any email — new customers and providers are stored in mock memory for the session.

## What works in mock mode

- Role selection → customer/provider sign in & sign up
- Browse categories & services, search, service detail
- Create bookings (auto-assigned to demo provider)
- Booking list, cancel, status updates (provider accept/start/complete)
- Chat with messages (pre-seeded on sample booking)
- Submit reviews
- Profile edit
- Provider onboarding (document upload simulated)
- Light/dark theme + default platform colors

## Switch to real backend

```env
USE_MOCK_AUTH=false
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

Use the same Project URL and anon/publishable key as `App/admin/.env.local`. Restart the app after changing `.env`.
