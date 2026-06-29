# My Bloc App

Flutter Clean Architecture boilerplate with **BLoC** state management, mirroring the OOSC app architecture patterns.

## Architecture

```
lib/
├── data/           → APIs, local storage, repository implementations  [README](lib/data/README.md)
├── domain/         → entities, params, repository interfaces, use cases  [README](lib/domain/README.md)
├── presentation/   → blocs, screens, common widgets, routes  [README](lib/presentation/README.md)
├── core/           → dio, config, utils, use case base  [README](lib/core/README.md)
├── constants/      → colors, theme, text  [README](lib/constants/README.md)
└── di/             → GetIt service locator  [README](lib/di/README.md)
```

Each folder has a **README.md** with a full folder/file map (what every subfolder and file does) plus how to implement new features.

## Layers

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI + BLoC (events/states) |
| **Domain** | Business logic via use cases + repository contracts |
| **Data** | API calls, local storage, repository implementations |
| **Core** | Shared infrastructure (Dio, exceptions, validation) |

## Getting Started

```bash
cp .env.example .env
flutter pub get
flutter run
```

## How to Add a New Feature

1. Create entity in `domain/entities/`
2. Create params in `domain/params/`
3. Add repository interface in `domain/repository_interfaces/`
4. Add API interface + impl in `data/data_sources/remote/apis/`
5. Add repository impl in `data/repository/`
6. Create use case(s) in `domain/usecases/`
7. Create BLoC (event, state, bloc) in `presentation/blocs/`
8. Build screen in `presentation/screens/`
9. Register DI in network, repository, domain, and presentation modules
10. Add route in `presentation/routes/app_router.dart`

## Auth Flow

```
Splash → AuthCheckRequested → Home (if logged in) / SignIn (if not)
SignIn → SignInRequested → API → save token → Home
Profile → SignOutRequested → clear storage → SignIn
```

## Commands

```bash
flutter analyze
flutter test
flutter pub run build_runner build --delete-conflicting-outputs
```

## MobX → BLoC Mapping

| MobX | BLoC |
|------|------|
| `stores/` | `blocs/` |
| `@observable` | State class fields |
| `@action` | Event handlers |
| `Observer` | `BlocBuilder` / `BlocListener` |

## .env
API_BASE_URL=https://api.example.com
API_CONNECTION_TIMEOUT=30000
API_RECEIVE_TIMEOUT=30000
FLAVOR=dev
USE_MOCK_AUTH=true