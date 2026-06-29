# Constants Layer

App-wide static values — colors, typography, copy, assets, theme definitions.

## Folder & file reference

Every file in `constants/` and what it does:

```
constants/
├── app_colors.dart           # Raw color palette (primary, background, error, etc.)
├── app_text.dart             # All UI strings — Sign In, Home, Appearance, etc.
├── app_theme.dart            # ThemeData for light + dark; wires AppThemeExtension
├── app_theme_extension.dart  # Semantic tokens: textPrimary, surface, drawerBackground
├── assets.dart               # Asset path constants (images, icons, fonts)
└── font_family.dart          # Font family name strings
```

### File purpose summary

| File | Purpose | Used by |
|------|---------|---------|
| `app_colors.dart` | Base hex colors — building blocks | `app_theme.dart`, `app_theme_extension.dart` |
| `app_text.dart` | User-visible copy — keeps strings out of widgets | All screens, drawer, forms |
| `app_theme.dart` | `AppTheme.light` / `AppTheme.dark` ThemeData | `main.dart` MaterialApp |
| `app_theme_extension.dart` | Semantic colors that adapt to light/dark | Widgets via `context.appTheme` |
| `assets.dart` | Paths like `assets/images/logo.png` | Widgets using `Image.asset` |
| `font_family.dart` | Font name constants | `app_theme.dart` text styles |

### How theme pieces connect

```
app_colors.dart          → raw colors
app_theme_extension.dart → semantic colors (light + dark variants)
app_theme.dart           → ThemeData + registers extension
theme_context.dart       → context.appTheme / context.colors in widgets
```

---

## Rules

- No imports from `data/`, `domain/`, or `presentation/`
- **Don't hardcode** values that belong in config:

| Value type | Put it in |
|------------|-----------|
| API base URL | `.env` → `FlavorConfig` |
| Endpoint paths | `data/.../network_constants.dart` |
| Feature flags from server | Remote config / backend |
| User data | Domain entities + local storage |

---

## When adding a feature

### Strings — `app_text.dart`

```dart
static const dashboardTitle = 'Dashboard';
static const totalUsers = 'Total users';
```

Use: `Text(AppText.dashboardTitle)`

### Colors — `app_colors.dart` + `app_theme_extension.dart`

Add raw color → expose semantic name → use `context.appTheme.myColor`

### Assets — `assets.dart` + `pubspec.yaml`

```dart
static const logo = 'assets/images/logo.png';
```

---

## See also

| Layer | README |
|-------|--------|
| Presentation | [presentation/README.md](../presentation/README.md) |
| Core | [core/README.md](../core/README.md) |
