# fleet_manager

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Setup notes for Supabase, Maps and GPS
 - Copy `.env.example` to `.env` and fill `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `MAPS_API_KEY`.
 - Run `flutter pub get`.
 - Android: add `MAPS_API_KEY` to your Android manifest placeholders or to `local.properties` and configure `android/app/build.gradle` manifestPlaceholders if needed. The manifest includes a `${MAPS_API_KEY}` placeholder.
 - iOS: add your Google Maps API key into AppDelegate or Info.plist if using native maps.
 - Initialize Supabase at app startup by calling `await SupabaseService.init()` before `runApp()`.
 - Request location permissions using `LocationService.requestPermission()` before accessing GPS.
