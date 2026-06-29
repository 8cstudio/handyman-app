# Presentation Layer

UI — screens, widgets, BLoC/Cubit state, navigation. No direct API or repository calls.

## Folder & file reference

Every subfolder and file in `presentation/` and what it does:

```
presentation/
├── blocs/                            # State management
│   ├── auth/
│   │   ├── auth_bloc.dart            # Handles sign-in, sign-up, sign-out, session check
│   │   ├── auth_event.dart           # AuthCheckRequested, SignInRequested, etc.
│   │   └── auth_state.dart           # AuthInitial, AuthLoading, AuthAuthenticated, etc.
│   └── theme/
│       └── theme_cubit.dart          # Light / dark / system theme (Cubit, not BLoC)
│
├── screens/                          # Full-page widgets — one folder per feature
│   ├── auth/
│   │   ├── README.md                 # Mock vs real auth setup guide
│   │   ├── sign_in_screen.dart       # Login form → dispatches SignInRequested
│   │   └── sign_up_screen.dart       # Register form → dispatches SignUpRequested
│   ├── splash/
│   │   └── splash_screen.dart        # App entry — AuthCheckRequested → home or sign-in
│   ├── home/
│   │   └── home_screen.dart          # Dashboard placeholder (drawer, profile nav)
│   └── profile/
│       └── profile_screen.dart       # Shows user info, sign-out button
│
├── common/                           # Reusable widgets across screens
│   ├── app_widgets.dart              # AppScaffold, AppButton, AppTextField, LoadingOverlay, ErrorView
│   └── app_drawer.dart               # Side drawer: profile link, theme dropdown
│
├── routes/                           # Navigation (GoRouter)
│   ├── app_routes.dart               # AppRoute enum — all paths + names (single source of truth)
│   ├── app_router.dart               # GoRouter config, auth redirect logic
│   ├── route_extensions.dart         # context.goAppRoute(AppRoute.home)
│   └── modules/                      # Route groups — split as app grows
│       ├── auth_route_module.dart    # splash, sign-in, sign-up routes
│       └── app_route_module.dart     # home, profile routes
│
└── di/
    └── presentation_layer_injection.dart  # Registers AuthBloc, ThemeCubit
```

### File purpose summary

| File | Purpose |
|------|---------|
| `blocs/auth/auth_bloc.dart` | Auth state machine; calls auth use cases only |
| `blocs/auth/auth_event.dart` | User/system triggers (tap sign-in, app start, etc.) |
| `blocs/auth/auth_state.dart` | What UI renders (loading, logged in, error) |
| `blocs/theme/theme_cubit.dart` | Theme mode state; simpler than BLoC (no events file) |
| `screens/splash/splash_screen.dart` | Restores session from local storage on cold start |
| `screens/auth/sign_in_screen.dart` | Email/password form + validation |
| `screens/auth/sign_up_screen.dart` | Name/email/password form |
| `screens/home/home_screen.dart` | Main screen after login |
| `screens/profile/profile_screen.dart` | User details + sign out |
| `common/app_widgets.dart` | Shared layout and form components |
| `common/app_drawer.dart` | Navigation drawer + theme selector |
| `routes/app_routes.dart` | Central route registry — add new routes here first |
| `routes/app_router.dart` | Wires routes + redirects unauthenticated users |
| `routes/route_extensions.dart` | `goAppRoute` / `pushAppRoute` helpers |
| `routes/modules/*.dart` | Feature-grouped GoRoute lists |
| `di/presentation_layer_injection.dart` | GetIt registration for blocs/cubits |

### BLoC vs Cubit

| Folder | Pattern | When to use |
|--------|---------|-------------|
| `blocs/auth/` | BLoC (event + state) | Multi-step flows, many triggers |
| `blocs/theme/` | Cubit | Simple toggle, one state type |

### Conventions for new features

| Add this | Location | Name pattern |
|----------|----------|--------------|
| State machine | `blocs/{feature}/` | `{feature}_bloc.dart`, `_event.dart`, `_state.dart` |
| Simple toggle | `blocs/{feature}/` | `{feature}_cubit.dart` |
| Screen | `screens/{feature}/` | `{name}_screen.dart` |
| Shared widget | `common/` | descriptive name |
| New route | `routes/app_routes.dart` + `routes/modules/` | Add to `AppRoute` enum |

---

## Rules

- May import `domain/` and `core/` — **never `data/` directly**
- Widgets dispatch events → BLoC → use case (never call repository)
- Side effects (navigation, snackbars): `BlocListener`
- UI rebuilds: `BlocBuilder` or `BlocSelector`
- Navigate: `context.goAppRoute(AppRoute.home)`

---

# End-to-end: Add API data to HomeScreen

Example: fetch dashboard stats from `GET /dashboard/stats` and display on Home.

## Flow

```
HomeScreen → HomeStatsRequested → HomeBloc → GetDashboardStatsUseCase
  → DashboardRepository → DashboardApiImpl → Dio → HomeLoaded → UI
```

## Checklist

| # | Layer | File | Action |
|---|-------|------|--------|
| 1 | Domain | `entities/dashboard/dashboard_stats_entity.dart` | Model |
| 2 | Domain | `repository_interfaces/dashboard_repository.dart` | Abstract repo |
| 3 | Domain | `usecases/dashboard/get_dashboard_stats_use_case.dart` | Use case |
| 4 | Data | `network_constants.dart` | Add path |
| 5 | Data | `apis/dashboard/dashboard_api.dart` + `_impl.dart` | HTTP |
| 6 | Data | `repository/dashboard_repository_impl.dart` | Repo impl |
| 7 | Data | `network_module` + `repository_module` | DI |
| 8 | Domain | `domain_layer_injection.dart` | Register use case |
| 9 | Presentation | `blocs/home/` — bloc, event, state | State machine |
| 10 | Presentation | `presentation_layer_injection.dart` | Register bloc |
| 11 | Presentation | `screens/home/home_screen.dart` | BlocBuilder UI |
| 12 | Env | `.env` | `API_BASE_URL`, `USE_MOCK_AUTH=false` |

## BLoC + screen snippet

```dart
// home_screen.dart — provide bloc at screen level
BlocProvider(
  create: (_) => getIt<HomeBloc>()..add(const HomeStatsRequested()),
  child: BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) => switch (state) {
      HomeLoading() => const LoadingOverlay(),
      HomeLoaded(:final stats) => Text('Users: ${stats.totalUsers}'),
      HomeFailure(:final message) => ErrorView(message: message),
      _ => const SizedBox.shrink(),
    },
  ),
)
```

Copy the full auth pattern: [blocs/auth/](../blocs/auth/) + [screens/auth/sign_in_screen.dart](../screens/auth/sign_in_screen.dart).

---

## Other READMEs

| Layer | File |
|-------|------|
| Domain | [domain/README.md](../domain/README.md) |
| Data | [data/README.md](../data/README.md) |
| DI | [di/README.md](../di/README.md) |
| Core | [core/README.md](../core/README.md) |
| Constants | [constants/README.md](../constants/README.md) |
