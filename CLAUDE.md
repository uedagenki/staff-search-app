# CLAUDE.md — staff-search-app

This file provides guidance to Claude Code (claude.ai/code) when working with the Flutter frontend app.

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

## Tech Stack

- **Flutter 3.35.4 / Dart 3.9.2** — Fixed versions
- **State Management**: Provider only — no Riverpod/Bloc, do not introduce them
- **Backend connectivity**: `ApiClient` (`services/api_client.dart`) for Go API at `../staff-search-api/`
- **Local Auth**: `LocalAuthService` using SharedPreferences (active fallback when backend is unavailable)
- **Maps**: OpenStreetMap via `flutter_map` (not Google Maps)
- **Live Streaming**: Agora RTC Engine 6.3.2
- **Payments**: Stripe (`flutter_stripe`)
- **Firebase**: Configured but optional (Firestore, Auth, Storage, Messaging)

## Demo Accounts (work without backend via LocalAuthService)

- User: `demo@example.com` / `demo123`
- Staff: `staff-demo@example.com` / `demo123`

## Directory Structure (`lib/`)

```
lib/
├── main.dart                  # Entry point, MaterialApp routes
├── firebase_options.dart      # Firebase config (requires actual project setup)
├── config/
│   └── api_config.dart        # API base URL configuration
├── data/
│   └── mock_data.dart         # Static mock staff data used by HomeScreen
├── models/                    # Dart model classes
│   ├── api_response.dart      # Generic API response wrapper
│   ├── booking.dart
│   ├── gift.dart / gift_item.dart / gifter_level.dart
│   ├── headhunt_offer.dart
│   ├── job_category.dart
│   ├── live_stream.dart
│   ├── media_item.dart
│   ├── message.dart
│   ├── notification.dart
│   ├── payment.dart
│   ├── point_transaction.dart
│   ├── portfolio_photo.dart
│   ├── post.dart / staff_post.dart
│   ├── push_notification.dart
│   ├── review.dart
│   ├── staff.dart / staff_profile.dart / staff_story.dart
│   ├── store.dart
│   ├── tip_history.dart
│   ├── upload_result.dart
│   └── user.dart
├── providers/                 # ChangeNotifier providers
│   ├── auth_provider.dart     # Auth state, wraps ApiClient + LocalAuthService
│   ├── feed_provider.dart     # Post feed state
│   └── staff_provider.dart    # Staff profile state
├── services/                  # Business logic + API layer
│   ├── api_client.dart        # HTTP client for Go backend (base URL from api_config)
│   ├── app_mode_service.dart  # AppMode (user/staff) singleton ChangeNotifier
│   ├── local_auth_service.dart # SharedPreferences-based auth (no backend needed)
│   ├── auth_service.dart      # Firebase Auth (optional)
│   ├── google_sign_in_service.dart
│   ├── staff_service.dart     # Staff CRUD via API
│   ├── post_service.dart      # Post CRUD via API
│   ├── upload_service.dart    # Media upload via API
│   ├── media_service.dart     # Media URL handling
│   ├── booking_service.dart / firebase_booking_service.dart
│   ├── chat_service.dart
│   ├── export_service.dart
│   ├── favorite_service.dart
│   ├── fcm_service.dart
│   ├── follow_service.dart
│   ├── gifter_service.dart
│   ├── headhunt_service.dart
│   ├── live_stream_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   ├── payment_service.dart
│   ├── point_service.dart
│   ├── review_service.dart
│   ├── story_service.dart
│   ├── tip_service.dart
│   └── user_service.dart
├── screens/                   # UI screens organized by feature
│   ├── home_screen.dart       # Main feed (TikTok-style scroll)
│   ├── login_screen.dart / register_screen.dart
│   ├── staff_detail_screen.dart
│   ├── search_screen.dart / map_search_screen.dart
│   ├── feed/                  # Feed-related screens
│   ├── booking/               # Booking flow screens
│   ├── staff/                 # Staff-facing screens (dashboard, bookings, earnings)
│   ├── admin/                 # Content moderation
│   └── [50+ individual screens]
├── widgets/                   # Reusable widgets
│   ├── feed_post_item.dart
│   ├── gift_sending_widget.dart
│   ├── job_category_chips.dart / job_category_dropdown.dart
│   ├── portfolio_grid.dart
│   ├── qr_code_dialog.dart
│   ├── simple_mode_switcher.dart
│   ├── staff_card.dart
│   ├── staff_stats_row.dart
│   └── video_feed_player.dart
├── utils/
│   ├── screen_logger.dart
│   └── storage_helper.dart
└── admin/                     # Admin portal (separate module)
    ├── screens/               # admin_dashboard, admin_login, push_notifications, user/staff mgmt
    ├── services/              # admin_auth_service.dart
    └── models/
```

## Key Architectural Decisions

**Dual Auth System**: The app has two auth implementations:
- `LocalAuthService` — active, SharedPreferences-based, no Firebase/backend needed.
- `auth_service.dart` — Firebase Auth, requires `firebase_options.dart` to be configured.
- `AuthProvider` + `ApiClient` — connects to Go backend for production auth.

**AppMode (user/staff)**: `AppModeService` is a singleton `ChangeNotifier` that manages whether the current session is in user mode or staff mode. Users can switch modes. Persisted via SharedPreferences.

**API Integration**: `ApiClient` in `services/api_client.dart` handles all HTTP communication with the Go backend. Base URL configured in `config/api_config.dart`.

**Admin Portal**: Accessed via `/admin` route → `AdminLoginScreen`. Implemented under `lib/admin/` as a semi-separate module with its own auth (`AdminAuthService`).

**Platform-specific stubs**: Some screens have `.dart.web_only` and `_stub.dart` variants for Agora live streaming (not available on web). See `live_broadcaster_screen_stub.dart` and `live_viewer_screen_stub.dart`.

**Mock Data**: `HomeScreen` loads from `lib/data/mock_data.dart` (static list). Staff profiles registered via the app are persisted in SharedPreferences and loaded separately.

## Firebase Setup (Optional — Required for Full Functionality)

Firebase is not configured by default. To enable:
1. Create a Firebase project and add Android/web apps
2. Place `google-services.json` in `android/app/`
3. Update `lib/firebase_options.dart` with actual config values
4. Enable Firestore Database and Email/Password Authentication in Firebase Console
5. See `FIREBASE_SETUP_REQUIRED.md` for detailed steps

## Package Version Locking

Firebase packages are pinned (not using `^`). Do not upgrade without testing:
- `firebase_core: 3.6.0`, `cloud_firestore: 5.4.3`, `firebase_auth: 5.3.1`, `firebase_storage: 12.3.2`, `firebase_messaging: 15.1.3`
