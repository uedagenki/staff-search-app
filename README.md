# staff-search-app

Flutter frontend for **staffsearch** — TikTok-style platform connecting customers with service staff.

## Stack

- **Flutter 3** · Dart SDK ^3.9
- **Provider** — state management
- **http** — REST API client
- **flutter_secure_storage** — token persistence
- **google_sign_in** — Google OAuth
- Targets: iOS, Android, Web

## Requirements

- Flutter SDK 3.x (`flutter --version`)
- Xcode (iOS) or Android Studio (Android)
- Backend API running (see `staff-search-api/`)

## Quick start

```bash
# 1. Enter directory
cd staff-search-app

# 2. Install dependencies
flutter pub get

# 3. Set API base URL
# Edit lib/config/api_config.dart
const String kApiBaseUrl = 'http://localhost:8080';

# 4. Run on a simulator / device
flutter run

# Run on specific platform
flutter run -d ios
flutter run -d android
flutter run -d chrome
```

## API config

Edit `lib/config/api_config.dart`:

```dart
// Local dev
const String kApiBaseUrl = 'http://localhost:8080';

// Production
const String kApiBaseUrl = 'https://api.staffsearch.jp';
```

> On Android emulator use `http://10.0.2.2:8080` instead of `localhost`.

## Build

```bash
# iOS (requires Mac + Xcode)
flutter build ios --release

# Android APK
flutter build apk --release

# Web
flutter build web --release
```

## Project structure

```
lib/
├── config/           # API base URL, constants
├── models/           # Data models (Staff, Post, Booking…)
├── providers/        # AuthProvider, StaffProvider, FeedProvider
├── screens/          # All screens by feature
│   ├── staff/        # Staff-side screens
│   ├── booking/      # Booking flow
│   ├── feed/         # Post / feed screens
│   └── admin/        # Admin screens
├── services/         # API service classes
├── widgets/          # Reusable UI components
├── utils/            # Helpers (storage, screen logger)
└── main.dart
```

## Demo accounts

Requires demo seed data loaded in the backend (`seeds/demo_data.sql`).

| Role | Email | Password |
|---|---|---|
| User | `user@demo.com` | `demo123` |
| Staff | `staff@demo.com` | `demo123` |
