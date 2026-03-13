# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**staffsearch (スタッフサーチ)** — A TikTok-style Flutter app connecting customers with service staff (beauticians, nail artists, massage therapists, etc.). Features include staff discovery, online booking, live streaming, tip/gift payments, and messaging.

## Common Commands

```bash
# Run the app
flutter run

# Run web build (served locally)
flutter build web --release
cd build/web && python3 -m http.server 5060 --bind 0.0.0.0

# Build Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Architecture

### Tech Stack
- **Flutter 3.35.4 / Dart 3.9.2** — Fixed versions
- **State Management**: Provider (no Riverpod/Bloc)
- **Backend**: Firebase (Firestore, Auth, Storage, Messaging) — configured but requires setup
- **Local Auth**: `LocalAuthService` using SharedPreferences (active fallback when Firebase is not configured)
- **Maps**: OpenStreetMap via `flutter_map` (not Google Maps despite spec references)
- **Live Streaming**: Agora RTC Engine 6.3.2
- **Payments**: Stripe (`flutter_stripe`)

### Directory Structure (`lib/`)

```
lib/
├── main.dart              # Entry point, MaterialApp routes, no Provider setup at root
├── firebase_options.dart  # Firebase config (requires actual project setup)
├── data/
│   └── mock_data.dart     # Static mock staff data used by HomeScreen
├── models/                # Dart model classes (User, Staff, Booking, etc.)
├── services/              # Business logic layer
│   ├── app_mode_service.dart       # AppMode enum (user/staff), mode switching, singleton ChangeNotifier
│   ├── local_auth_service.dart     # LocalAuthService: SharedPreferences-based auth (primary auth)
│   ├── auth_service.dart           # Firebase-based auth (requires Firebase setup)
│   ├── firebase_booking_service.dart  # Firebase Firestore bookings
│   ├── booking_service.dart        # Local/mock booking service
│   └── [other services]            # chat, payment, notifications, live stream, etc.
├── screens/               # UI screens organized by feature
│   ├── home_screen.dart   # Main feed (TikTok-style scroll), uses MockData
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── staff/             # Staff-facing screens (dashboard, bookings, earnings, etc.)
│   ├── booking/           # Booking flow screens
│   └── admin/             # Content moderation screen (note: in screens/admin/, not lib/admin/)
└── admin/                 # Admin portal (separate from main app)
    ├── screens/           # admin_dashboard, admin_login, push_notifications, user/staff mgmt
    ├── services/          # admin_auth_service.dart
    └── models/
```

### Key Architectural Decisions

**Dual Auth System**: The app has two auth implementations:
- `LocalAuthService` — active, SharedPreferences-based, no Firebase needed. Demo accounts: `demo@example.com` / `demo123` (user) and `staff-demo@example.com` / `demo123` (staff).
- `auth_service.dart` — Firebase Auth, requires `firebase_options.dart` to be configured.

**AppMode (user/staff)**: `AppModeService` is a singleton `ChangeNotifier` that manages whether the current session is in user mode or staff mode. Users can switch modes if logged into both accounts. Persisted via SharedPreferences.

**Admin Portal**: Accessed via `/admin` route → `AdminLoginScreen`. Implemented under `lib/admin/` as a semi-separate module with its own auth (`AdminAuthService`).

**Platform-specific stubs**: Some screens have `.dart.web_only` and `_stub.dart` variants for Agora live streaming (not available on web). See `live_broadcaster_screen_stub.dart` and `live_viewer_screen_stub.dart`.

**Mock Data**: `HomeScreen` loads from `lib/data/mock_data.dart` (static list). Staff profiles registered via the app are persisted in SharedPreferences and loaded separately via `_loadStaffFromLocalStorage()`.

### Firebase Setup (Required for Full Functionality)

Firebase is not configured by default. To enable:
1. Create a Firebase project and add Android/web apps
2. Place `google-services.json` in `android/app/`
3. Update `lib/firebase_options.dart` with actual config values
4. Enable Firestore Database and Email/Password Authentication in Firebase Console
5. See `FIREBASE_SETUP_REQUIRED.md` for detailed steps

### Firestore Collections
- `users/{userId}` — user profiles with role (`user`|`staff`|`admin`), points, privacy policy consent
- `bookings/{bookingId}` — reservations linking userId ↔ staffId ↔ serviceId
- `services/{serviceId}` — staff service menus

### Package Version Locking
Firebase packages are pinned (not using `^`). Do not upgrade without testing:
- `firebase_core: 3.6.0`, `cloud_firestore: 5.4.3`, `firebase_auth: 5.3.1`, `firebase_storage: 12.3.2`, `firebase_messaging: 15.1.3`
