# Domain Layer

Business logic contracts — no Flutter UI, no HTTP, no platform code.

## Folder & file reference

Every subfolder and file in `domain/` and what it does:

```
domain/
├── entities/                         # Business models returned by repos/APIs
│   ├── common/
│   │   └── api_response.dart         # Generic wrapper { success, message, data }
│   └── user/
│       └── user_entity.dart          # User model: id, name, email, accessToken
│
├── params/                           # Input models sent TO APIs/repos
│   └── auth/
│       ├── sign_in_params.dart       # email + password for login
│       └── sign_up_params.dart       # name + email + password for register
│
├── repository_interfaces/            # Abstract contracts — NO implementation here
│   ├── auth_repository.dart          # signIn, signUp, signOut, getCurrentUser
│   └── theme_repository.dart         # getThemeMode, setThemeMode
│
├── usecases/                         # One class = one app action
│   ├── auth/
│   │   ├── sign_in_use_case.dart     # Calls AuthRepository.signIn
│   │   ├── sign_up_use_case.dart     # Calls AuthRepository.signUp
│   │   ├── sign_out_use_case.dart    # Calls AuthRepository.signOut
│   │   └── get_current_user_use_case.dart  # Calls AuthRepository.getCurrentUser
│   └── theme/
│       ├── get_theme_mode_use_case.dart    # Reads saved theme
│       └── set_theme_mode_use_case.dart    # Saves theme preference
│
└── di/
    └── domain_layer_injection.dart   # Registers all use cases in GetIt
```

### File purpose summary

| File | Purpose |
|------|---------|
| `entities/user/user_entity.dart` | User data model; `fromJson` / `toJson` for API + local storage |
| `entities/common/api_response.dart` | Parses `{ "success", "message", "data" }` API envelopes |
| `params/auth/sign_in_params.dart` | Login form → API body |
| `params/auth/sign_up_params.dart` | Register form → API body |
| `repository_interfaces/auth_repository.dart` | Defines what auth data layer must provide |
| `repository_interfaces/theme_repository.dart` | Defines theme read/write contract |
| `usecases/auth/*.dart` | Thin wrappers — BLoC calls these, not repos directly |
| `usecases/theme/*.dart` | Theme read/write use cases for `ThemeCubit` |
| `di/domain_layer_injection.dart` | `getIt.registerLazySingleton` for every use case |

### Conventions for new features

| Add this | In this folder | Name pattern |
|----------|----------------|--------------|
| Response model | `entities/{feature}/` | `{name}_entity.dart` |
| Request body | `params/{feature}/` | `{action}_params.dart` |
| Repo contract | `repository_interfaces/` | `{feature}_repository.dart` |
| App action | `usecases/{feature}/` | `{verb}_{noun}_use_case.dart` |

---

## Rules

- **Must NOT** import from `data/` or `presentation/`
- May import from `core/` and `constants/`
- Repositories are **interfaces only** — implementations live in `data/`

---

## How to add a feature (domain steps)

Example: **dashboard stats on HomeScreen** (`GET /dashboard/stats`).

### 1. Entity — `entities/dashboard/dashboard_stats_entity.dart`

```dart
class DashboardStatsEntity extends Equatable {
  final int totalUsers;
  final int activeSessions;
  // fromJson, toJson, props
}
```

### 2. Repository interface — `repository_interfaces/dashboard_repository.dart`

```dart
abstract class DashboardRepository {
  Future<DashboardStatsEntity> getStats();
}
```

### 3. Use case — `usecases/dashboard/get_dashboard_stats_use_case.dart`

```dart
class GetDashboardStatsUseCase implements UseCaseNoParams<DashboardStatsEntity> {
  final DashboardRepository _repository;
  @override
  Future<DashboardStatsEntity> call() => _repository.getStats();
}
```

### 4. Register — `di/domain_layer_injection.dart`

```dart
getIt.registerLazySingleton(
  () => GetDashboardStatsUseCase(getIt<DashboardRepository>()),
);
```

---

## Next layers

| Layer | README |
|-------|--------|
| Data | [data/README.md](../data/README.md) |
| Presentation | [presentation/README.md](../presentation/README.md) — **full end-to-end guide** |
| DI | [di/README.md](../di/README.md) |
