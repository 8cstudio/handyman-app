# Core Layer

Shared infrastructure used by all layers — networking, config, base classes, utilities.

## Folder & file reference

Every subfolder and file in `core/` and what it does:

```
core/
├── config/
│   └── flavors/
│       └── flavors.dart              # AppFlavor enum + FlavorConfig singleton
│                                       # Holds: baseUrl, timeouts, useMockAuth from .env
│
├── dio/                              # HTTP stack
│   ├── configs/
│   │   └── dio_configs.dart          # baseUrl, connectionTimeout, receiveTimeout holder
│   ├── interceptor/
│   │   └── auth_interceptor.dart     # Adds Bearer token to outgoing requests
│   │                                 # LoggingInterceptor — debug HTTP logs
│   ├── exception/
│   │   └── api_exception.dart        # Maps DioException → user-friendly message
│   ├── auth_token_provider.dart      # Interface for reading access token (implemented by auth local DS)
│   └── dio_client.dart               # Wraps Dio: get(), post(), put(), delete()
│
├── theme/
│   └── theme_context.dart            # BuildContext extensions: context.appTheme, context.colors
│
├── usecase/
│   └── usecase.dart                  # UseCase<T,P> and UseCaseNoParams<T> base classes
│
└── utils/
    └── validation_utils.dart         # validateEmail, validatePassword, validateRequired
```

### File purpose summary

| File | Purpose |
|------|---------|
| `config/flavors/flavors.dart` | Single place for env-driven config; read once in `main.dart` |
| `dio/configs/dio_configs.dart` | Plain data class passed to DioClient |
| `dio/dio_client.dart` | All API impls use this — never create raw Dio instances |
| `dio/auth_token_provider.dart` | Abstraction so interceptor doesn't depend on data layer directly |
| `dio/interceptor/auth_interceptor.dart` | Injects `Authorization: Bearer {token}` header |
| `dio/interceptor/auth_interceptor.dart` (LoggingInterceptor) | Prints `[HTTP] POST url` in debug |
| `dio/exception/api_exception.dart` | Typed errors BLoC catches and shows to user |
| `theme/theme_context.dart` | Shortcuts for theme colors in widgets |
| `usecase/usecase.dart` | Every domain use case implements one of these interfaces |
| `utils/validation_utils.dart` | Form validation used in sign-in/sign-up screens |

### Who imports core?

| Consumer | Uses |
|----------|------|
| `data/` | DioClient, ApiException |
| `domain/` | UseCase base classes |
| `presentation/` | ApiException, theme_context, validation_utils |
| `main.dart` | FlavorConfig |

---

## Rules

- **No imports** from `data/`, `domain/`, or `presentation/`
- Any layer may import from `core/`

---

## When adding a new API feature

Usually **no new core files** — use existing Dio + ApiException.

| Need | Where to add |
|------|--------------|
| New env variable | `.env` → `flavors.dart` → `main.dart` |
| New interceptor | `dio/interceptor/` → register in `network_module` |
| Shared validation | `utils/validation_utils.dart` |
| New base class | `usecase/` or `utils/` |

### Request path (already wired)

```
API impl → DioClient → AuthInterceptor (token) → LoggingInterceptor → network
```

---

## Environment (`.env`)

```env
API_BASE_URL=https://your-api.com
API_CONNECTION_TIMEOUT=30000
API_RECEIVE_TIMEOUT=30000
USE_MOCK_AUTH=false
FLAVOR=dev
```

Restart app after changes — hot reload does not reload `.env`.

---

## See also

| Layer | README |
|-------|--------|
| Data | [data/README.md](../data/README.md) |
| DI | [di/README.md](../di/README.md) |
