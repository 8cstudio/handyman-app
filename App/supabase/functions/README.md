# Deprecated — use Next.js API instead

Backend logic has moved to **Next.js API routes** in `App/admin`:

```
POST/GET/PUT/DELETE  /api/v1/{handler-name}
```

Examples:
- `/api/v1/auth-sign-in`
- `/api/v1/bookings-list`
- `/api/v1/admin-companies-crud`

These Deno edge function folders are kept for reference only. **Do not deploy** them unless you intentionally revert to the edge-function architecture.

Run the admin app (`cd App/admin && npm run dev`) — all API calls go through port 3000.
