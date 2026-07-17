# CashStack — Flutter App

The Flutter client foundation for CashStack, a personal finance app. This
repository currently ships the **application architecture only** — theming,
routing, networking, authentication, and reusable UI primitives. Business
screens (transactions, budgets, reports, dashboard, …) are intentionally not
implemented yet; they plug into the structure documented below.

## Tech Stack

- Flutter 3 (Material 3)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) for state management
- [go_router](https://pub.dev/packages/go_router) for declarative, auth-aware routing
- [dio](https://pub.dev/packages/dio) for networking
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) for token storage
- [google_fonts](https://pub.dev/packages/google_fonts) for typography
- [material_symbols_icons](https://pub.dev/packages/material_symbols_icons) for Material Symbols
- [intl](https://pub.dev/packages/intl) for localization/formatting

## Project Structure

```
lib/
  core/                    Infrastructure shared by the whole app
    config/                 Compile-time config (API base URL, flags)
    constants/               8pt spacing scale, border-radius scale,
                              durations, storage keys, app-wide constants
    error/                   Failure/AppException/Result types + mapping
    extensions/               BuildContext/num/DateTime formatting helpers
    network/                 Dio client, interceptors, auth event bus
    storage/                 SecureStorageService (JWT persistence)
    theme/                   Material 3 colors, typography, ThemeData
    utils/                   Framework-agnostic helpers (validators, …)
    widgets/                 The design system (see below)

  shared/
    models/                  ApiResponse<T>, PaginatedResponse<T>
    widgets/                  Barrel re-export of core/widgets — import
                               the whole design system from here

  services/                App-level singleton services
    snackbar_service.dart      Global success/error/warning/info snackbars

  routes/                  GoRouter configuration
    app_routes.dart            Route path constants
    app_router.dart            Router + auth redirect guard
    main_shell.dart             Bottom-nav shell for the authenticated area

  features/                One folder per feature
    <feature>/
      screens/                UI screens (ConsumerWidget/ConsumerStatefulWidget)
      widgets/                 Feature-local widgets
      providers/                Riverpod state (Notifier/AsyncNotifier)
      models/                    Data models (fromJson, Equatable)
      repositories/              Presentation-facing API (returns Result<T>)
      data_sources/              Raw Dio calls (throws AppException)

    auth/                    Splash-adjacent auth flow: login, register,
                               forgot password, session restore, logout
    splash/                  Splash screen shown while the session is checked
    home/                    Placeholder home tab
    profile/                 Placeholder profile tab (+ logout entry point)
    settings/                Placeholder settings tab
```

### Layering rule

`Screen → Riverpod Notifier → Repository → Remote Data Source → Dio`

- **Screens** never call Dio or a data source directly, and contain no
  business logic — only form state and calling the controller.
- **Repositories** are the only thing screens/controllers talk to. They
  return `Result<T>` (`Ok<T>` / `Err<T>`, see `core/error/result.dart`)
  instead of throwing, so failures are handled explicitly.
- **Data sources** are the only thing that touches `Dio` directly. They
  throw `AppException`s (never a raw `DioException`).

Every new feature should follow the same `screens / widgets / providers /
models / repositories / data_sources` layout used by `auth`.

## Getting Started

### Prerequisites

- Flutter 3 (stable channel)
- A running instance of the CashStack backend (see `../cashstack-backend`)

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Point the app at your backend

The API base URL is a compile-time `--dart-define`, defaulting to the
hosted backend at `https://cashstack.madhan.dev/api/v1`. Override it as
needed:

```bash
# Hosted backend (default, no flag needed)
flutter run

# Local backend, Android emulator (10.0.2.2 is the emulator's alias for the host machine's localhost)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1

# Local backend, iOS simulator / physical device on the same network
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api/v1
```

### 3. Run

```bash
flutter run
```

## Authentication Flow

1. On launch, `SplashScreen` is shown while `AuthController` checks for a
   stored refresh token and, if present, validates it via `GET /users/me`.
2. If there's no valid session, the router redirects to `LoginScreen`.
   Unauthenticated users are always sent to Login — there is no way to reach
   a protected route without a valid session.
3. `LoginScreen` / `RegisterScreen` call `AuthController.login` /
   `.register`. On success the controller's state becomes `authenticated`
   and the router (which listens to that state via `refreshListenable`)
   automatically redirects to the home shell.
4. Access and refresh tokens are persisted via `SecureStorageService`
   (`flutter_secure_storage`) — never in memory-only state, never in
   `SharedPreferences`.
5. Every authenticated request goes through `AuthInterceptor` (attaches the
   access token) and `RefreshTokenInterceptor`: on a 401, it refreshes the
   token exactly once (concurrent 401s share a single in-flight refresh),
   retries the original request, and — if the refresh token itself is
   rejected — clears the session and emits `AuthEventBus.onSessionExpired`.
   `AuthController` listens for that event and flips back to
   `unauthenticated`, which the router picks up and redirects to Login.
6. `ProfileScreen` has a "Log out" button that calls
   `AuthController.logout()`, which best-effort notifies the backend and
   always clears local tokens.

## Networking

`core/network/dio_client.dart` builds one `Dio` instance with, in order:

1. **AuthInterceptor** — attaches `Authorization: Bearer <token>` unless the
   request is flagged `RequestFlags.skipAuth` (login/register/refresh/etc).
2. **RefreshTokenInterceptor** — the 401-retry-with-refresh logic described
   above.
3. **ErrorInterceptor** — maps every `DioException` to a domain
   `AppException`, attached via `DioException.error` so data sources can
   read it with the `DioExceptionX.appException` extension instead of
   re-deriving it from status codes.
4. **LoggingInterceptor** — logs requests/responses via `dart:developer`
   (gated by `AppConfig.enableNetworkLogging`).

## Design System

Everything under `core/widgets/` is the app's design system — modern,
minimal, premium (CRED / Google Wallet / Revolut / Notion-inspired), built
on Material 3. Import the whole thing from one place:

```dart
import 'package:cashstack/shared/widgets/widgets.dart';
```

### Theme

`core/theme/app_theme.dart` builds Material 3 `ThemeData` for light and dark
mode from a single green seed color (`AppColors.seed = #16A34A`) via
`ColorScheme.fromSeed`, with the Inter typeface (Google Fonts) driving the
full type scale and every component (inputs, buttons, cards, chips,
snackbars, dialogs, sheets, nav bar, FAB) themed centrally — screens never
restyle a Material widget by hand.

Colors that don't fit `ColorScheme` (success/danger/warning/info,
income/expense, shimmer shades) are exposed per-brightness via a
`ThemeExtension`: `context.semanticColors.success`, `.danger`, `.income`,
`.expense`, etc. (`core/extensions/context_extensions.dart`).

### Typography

`core/theme/app_typography.dart` maps the brief's six levels onto Material
3's `TextTheme` slots:

| Level     | `TextTheme` slot(s)                          |
| --------- | --------------------------------------------- |
| Display   | `displayLarge` / `displayMedium` / `displaySmall` |
| Headline  | `headlineLarge` / `headlineMedium` / `headlineSmall` |
| Title     | `titleLarge` / `titleMedium` / `titleSmall`   |
| Body      | `bodyLarge` / `bodyMedium`                     |
| Caption   | `bodySmall`                                    |
| Button    | `labelLarge`                                   |

Access via `context.textStyles.titleMedium`, never `GoogleFonts.inter(...)`
directly in a screen.

### Spacing & radius

`core/constants/app_spacing.dart` is an 8-point scale (`xs=4, sm=8, md=16,
lg=24, xl=32, xxl=48, xxxl=64`); `core/constants/app_radius.dart` is the
one border-radius scale used everywhere (`xs=6 … xl=28`, plus `pill=999`
for fully-rounded controls). Every widget in the design system is built
from these two files — no magic numbers.

### Icons

[`material_symbols_icons`](https://pub.dev/packages/material_symbols_icons)
is included for Material Symbols (`Symbols.wallet`, etc); the design system
widgets themselves default to Material Icons (`Icons.*`) since every
`icon:` parameter is a plain `IconData`, so pass `Symbols.*` wherever you
want the newer glyph set.

### Component inventory (`core/widgets/`)

| Folder        | Widgets |
| -------------- | ------- |
| `buttons/`     | `AppPrimaryButton`, `AppSecondaryButton`, `AppOutlinedButton`, `AppTextButton` — all with `isLoading`, `fullWidth`, `AppButtonSize`, leading/trailing icons |
| `inputs/`      | `AppTextField`, `SearchTextField`, `PasswordTextField`, `CurrencyTextField`, `AppDropdown<T>`, `AppDatePickerField` / `showAppDatePicker` |
| `feedback/`    | `LoadingWidget` / `FullScreenLoading`, `CircularLoader`, `EmptyState`, `ErrorState` (+ `.fromFailure`) / `FullScreenError`, `NoDataWidget`, `showAppBottomSheet`, `ConfirmationDialog` / `showAppConfirmationDialog`, `buildAppSnackbar`, `AppToast`, `ShimmerLoading` / `ShimmerBox` / `ShimmerListPlaceholder` / `ShimmerCardPlaceholder` |
| `navigation/`  | `CashStackAppBar`, `AppBottomNavBar` (+ `AppNavDestination`) |
| `cards/`       | `AppCard`, `AppListTile`, `TransactionTile`, `CategoryChip`, `AccountCard`, `BudgetProgressCard`, `StatCard` |
| `misc/`        | `SectionHeader`, `AppFab` (+ `.extended`) |

All of them are presentation-only (primitive parameters in, no model/API
coupling) and themed entirely off `Theme.of(context)` — none hardcode a
color or text style.

### Feedback services

- `services/snackbar_service.dart` — `showSuccess` / `showError` /
  `showWarning` / `showInfo`, callable from anywhere (no `BuildContext`
  needed) via `ref.read(snackbarServiceProvider)`. Renders through the same
  `buildAppSnackbar` used by any screen that already has a `context`.
- `AppToast.show(context, message)` — for brief, non-blocking confirmations
  that shouldn't queue behind a snackbar.

## Localization

`intl` is wired in as a dependency and used for date/number formatting
utilities. The app ships English-only for now; no `.arb` files or generated
localization delegates have been added yet — that's the next step once
actual copy needs translating.

## Testing

```bash
flutter test
```

`test/widget_test.dart` is a smoke test verifying the app boots inside a
`ProviderScope` and reaches the splash screen.
