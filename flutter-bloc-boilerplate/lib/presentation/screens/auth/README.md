# Auth Screens

Sign-in and sign-up UI lives here. The flow is wired through Clean Architecture:

```
SignInScreen / SignUpScreen
  → AuthBloc
  → SignInUseCase / SignUpUseCase
  → AuthRepository
  → AuthApi (mock or remote)
  → AuthLocalDataSource (persists user + token)
```

## Current mode: mock auth (no backend)

There is **no backend URL yet**, so the app runs with **mock auth** enabled.

Set in `.env`:

```env
USE_MOCK_AUTH=true
```

When mock auth is on:

- **No HTTP calls** are made for sign-in, sign-up, or sign-out
- Any email/password that passes form validation will sign you in
- Sign-up uses the name, email, and password from the form
- User data and a fake access token are saved locally via `SharedPreferences`
- Splash restores the session from local storage on next launch

Implementation: `lib/data/data_sources/remote/apis/auth/auth_api_mock_impl.dart`

## When you have a real backend

### 1. Update `.env`

```env
API_BASE_URL=https://your-real-api.com
USE_MOCK_AUTH=false
FLAVOR=dev
```

Use your staging/production URL as needed. Do **not** commit secrets; keep `.env` local.

### 2. Restart the app

`.env` is loaded once at startup in `main.dart`. Hot reload is not enough — stop and run:

```bash
flutter run
```

### 3. Expected API contract

`AuthApiImpl` calls these endpoints (see `network_constants.dart`):

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/auth/sign-in` | `{ "email", "password" }` | User JSON |
| POST | `/auth/sign-up` | `{ "name", "email", "password" }` | User JSON |
| POST | `/auth/sign-out` | — | — |
| GET | `/auth/me` | — | User JSON |

User JSON shape (`UserEntity.fromJson`):

```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "access_token": "string"
}
```

Adjust field names in `UserEntity.fromJson` if your API differs.

### 4. Verify

1. Sign in with real credentials → should reach home
2. Kill and reopen app → splash should restore session from local storage
3. Sign out from profile → should return to sign-in

### 5. No code changes required

DI in `network_module.dart` already switches implementations:

- `USE_MOCK_AUTH=true` → `AuthApiMockImpl`
- `USE_MOCK_AUTH=false` → `AuthApiImpl` (Dio + `API_BASE_URL`)

Screens, BLoC, and use cases stay the same.

## Files

| File | Role |
|------|------|
| `sign_in_screen.dart` | Sign-in form + `SignInRequested` |
| `sign_up_screen.dart` | Sign-up form + `SignUpRequested` |
| `presentation/blocs/auth/` | Auth state machine |
| `data/.../auth_api_impl.dart` | Real HTTP auth |
| `data/.../auth_api_mock_impl.dart` | Local stub (current) |
| `data/repository/auth_repository_impl.dart` | API + local persistence |
