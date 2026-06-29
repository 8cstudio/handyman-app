# Data Layer

Talks to the outside world — HTTP APIs, local storage — and implements domain repository interfaces.

## Folder & file reference

Every subfolder and file in `data/` and what it does:

```
data/
├── data_sources/
│   ├── remote/                       # Network / HTTP
│   │   ├── constants/
│   │   │   └── network_constants.dart    # API path strings (/auth/sign-in, etc.)
│   │   └── apis/
│   │       └── auth/                     # One folder per feature
│   │           ├── auth_api.dart         # Abstract API contract
│   │           ├── auth_api_impl.dart    # Real HTTP calls via DioClient
│   │           └── auth_api_mock_impl.dart  # Offline stub when USE_MOCK_AUTH=true
│   │
│   └── local/                        # On-device persistence
│       ├── auth_local_data_source.dart   # Saves user JSON + access_token (SharedPreferences)
│       └── theme_local_data_source.dart # Saves theme_mode (light/dark/system)
│
├── repository/                     # Implements domain repository_interfaces/
│   ├── auth_repository_impl.dart     # API + local: login → save user, logout → clear
│   └── theme_repository_impl.dart    # Delegates to theme local data source
│
└── di/
    ├── data_layer_injection.dart     # Calls network + repository modules
    └── module/
        ├── network_module/
        │   └── network_module.dart   # Dio, interceptors, APIs, auth local source
        └── repository_module/
            └── repository_module.dart # Binds repository interfaces → implementations
```

### File purpose summary

| File | Purpose |
|------|---------|
| `remote/constants/network_constants.dart` | Central list of API endpoint paths — never hardcode paths in API impls |
| `remote/apis/auth/auth_api.dart` | Interface: signIn, signUp, signOut, getCurrentUser |
| `remote/apis/auth/auth_api_impl.dart` | POST/GET via `DioClient`; maps `DioException` → `ApiException` |
| `remote/apis/auth/auth_api_mock_impl.dart` | Fake auth without network; used when `USE_MOCK_AUTH=true` |
| `local/auth_local_data_source.dart` | Keys: `access_token`, `user_data` in SharedPreferences |
| `local/theme_local_data_source.dart` | Key: `theme_mode` in SharedPreferences |
| `repository/auth_repository_impl.dart` | Orchestrates API + local storage for auth flows |
| `repository/theme_repository_impl.dart` | Pass-through to theme local data source |
| `di/data_layer_injection.dart` | Entry: runs NetworkModule then RepositoryModule |
| `di/module/network_module/network_module.dart` | Registers Dio, AuthApi (mock or real), local sources |
| `di/module/repository_module/repository_module.dart` | Registers AuthRepository, ThemeRepository |

### Conventions for new features

| Add this | Location | Name pattern |
|----------|----------|--------------|
| Endpoint path | `remote/constants/network_constants.dart` | `static const String featureAction` |
| API contract | `remote/apis/{feature}/{feature}_api.dart` | |
| HTTP impl | `remote/apis/{feature}/{feature}_api_impl.dart` | |
| Mock (optional) | `remote/apis/{feature}/{feature}_api_mock_impl.dart` | |
| Local storage | `local/{feature}_local_data_source.dart` | Only if caching needed |
| Repo impl | `repository/{feature}_repository_impl.dart` | |

---

## Rules

- May import `domain/` and `core/` only
- **Must NOT** import `presentation/`
- Return **domain entities** from repositories, not raw maps

---

## How to add a feature (data steps)

Example: **dashboard stats** — continuing from domain layer.

### 1. Endpoint — `network_constants.dart`

```dart
static const String dashboardStats = '/dashboard/stats';
```

### 2. API — `remote/apis/dashboard/dashboard_api.dart` + `_impl.dart`

```dart
class DashboardApiImpl implements DashboardApi {
  Future<DashboardStatsEntity> getStats() async {
    final response = await _dioClient.get(NetworkConstants.dashboardStats);
    return DashboardStatsEntity.fromJson(response.data);
  }
}
```

### 3. Repository — `repository/dashboard_repository_impl.dart`

```dart
class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardStatsEntity> getStats() => _api.getStats();
}
```

### 4. DI — register in `network_module.dart` and `repository_module.dart`

---

## Mock vs real API

| `.env` | Auth uses |
|--------|-----------|
| `USE_MOCK_AUTH=true` | `AuthApiMockImpl` — no network |
| `USE_MOCK_AUTH=false` | `AuthApiImpl` — calls `API_BASE_URL` |

See [screens/auth/README.md](../presentation/screens/auth/README.md) for auth-specific notes.

---

## Next

| Layer | README |
|-------|--------|
| Domain | [domain/README.md](../domain/README.md) |
| Presentation | [presentation/README.md](../presentation/README.md) |
| DI | [di/README.md](../di/README.md) |
