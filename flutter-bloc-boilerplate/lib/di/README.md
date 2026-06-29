# DI (Dependency Injection)

GetIt service locator — wires all layers together at app startup.

## Folder & file reference

```
lib/
├── di/                               # Root DI entry
│   └── service_locator.dart          # getIt instance + configureDependencies()
│
├── data/di/                          # Data layer registrations
│   ├── data_layer_injection.dart     # Runs NetworkModule → RepositoryModule
│   └── module/
│       ├── network_module/
│       │   └── network_module.dart   # Dio, interceptors, AuthApi, local data sources
│       └── repository_module/
│           └── repository_module.dart # AuthRepository, ThemeRepository impls
│
├── domain/di/
│   └── domain_layer_injection.dart   # All use cases (SignIn, SignUp, theme, etc.)
│
└── presentation/di/
    └── presentation_layer_injection.dart  # AuthBloc (factory), ThemeCubit (singleton)
```

### File purpose summary

| File | Registers | Type |
|------|-----------|------|
| `di/service_locator.dart` | Calls all layer modules in order | Entry point |
| `data/di/data_layer_injection.dart` | Orchestrates data modules | Mixin |
| `data/di/module/network_module/network_module.dart` | `DioClient`, `AuthApi`, `AuthLocalDataSource`, interceptors | Lazy singletons |
| `data/di/module/repository_module/repository_module.dart` | `AuthRepository`, `ThemeRepository`, `ThemeLocalDataSource` | Lazy singletons |
| `domain/di/domain_layer_injection.dart` | `SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`, `GetCurrentUserUseCase`, theme use cases | Lazy singletons |
| `presentation/di/presentation_layer_injection.dart` | `ThemeCubit` (singleton), `AuthBloc` (factory) | Mixed |

### What is registered today

**NetworkModule**
- `AuthLocalDataSource`, `LoggingInterceptor`, `AuthInterceptor`
- `DioConfigs`, `DioClient`
- `AuthApi` → mock or real based on `USE_MOCK_AUTH`

**RepositoryModule**
- `ThemeLocalDataSource`, `ThemeRepository`, `AuthRepository`

**DomainLayerInjection**
- Auth: `SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`, `GetCurrentUserUseCase`
- Theme: `GetThemeModeUseCase`, `SetThemeModeUseCase`

**PresentationLayerInjection**
- `ThemeCubit`, `AuthBloc`

---

## Startup order

`main.dart` → `ServiceLocator.configureDependencies()`:

```
1. DataLayerInjection     ← repos need APIs; APIs need Dio
2. DomainLayerInjection   ← use cases need repos
3. PresentationLayerInjection  ← blocs need use cases
```

**Order matters.** Never register a use case before its repository.

---

## Usage

```dart
import 'package:my_bloc_app/di/service_locator.dart';

final bloc = getIt<AuthBloc>();       // new instance (factory)
final cubit = getIt<ThemeCubit>();    // shared instance (singleton)
```

---

## Registration patterns

| Lifetime | GetIt method | Use for |
|----------|--------------|---------|
| One shared instance | `registerLazySingleton` | Dio, repos, use cases, ThemeCubit |
| New instance each call | `registerFactory` | BLoCs tied to a screen lifecycle |

---

## Adding a new feature — DI checklist

Example: **dashboard stats on Home**

| Step | File | Register |
|------|------|----------|
| 1 | `network_module.dart` | `DashboardApi` → `DashboardApiImpl` |
| 2 | `repository_module.dart` | `DashboardRepository` → `DashboardRepositoryImpl` |
| 3 | `domain_layer_injection.dart` | `GetDashboardStatsUseCase` |
| 4 | `presentation_layer_injection.dart` | `HomeBloc` (factory) |

`service_locator.dart` only changes if you add a **new top-level module**.

---

## Full feature guide

[presentation/README.md](../presentation/README.md) — complete 12-step flow from API to screen.

## Layer READMEs

| Layer | File |
|-------|------|
| Domain | [domain/README.md](../domain/README.md) |
| Data | [data/README.md](../data/README.md) |
| Presentation | [presentation/README.md](../presentation/README.md) |
| Core | [core/README.md](../core/README.md) |
| Constants | [constants/README.md](../constants/README.md) |
