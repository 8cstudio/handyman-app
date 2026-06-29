# Firebase Cloud Messaging (FCM)

Push notifications use **FlutterFire CLI** to pull config from your Firebase project and write the native Android/iOS files automatically.

## Prerequisites

Firebase CLI and FlutterFire CLI (already installed globally):

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## 1. Log in to Firebase (one-time, opens browser)

```bash
firebase login
```

## 2. Configure the Flutter app

Project: **`services-provider-b9462`** (display name: service-provider)

From `flutter-bloc-boilerplate` (after `firebase login`):

```bash
cd flutter-bloc-boilerplate

flutterfire configure \
  --yes \
  --project=services-provider-b9462 \
  --platforms=android,ios \
  --android-package-name=com.example.flutter_bloc \
  --ios-bundle-id=com.example.flutterBloc
```

> **Note:** If `flutterfire configure` fails on Kotlin Gradle (`.kts`), fetch configs manually:
> ```bash
> firebase apps:sdkconfig ANDROID 1:138471737210:android:90d093d39bf5f34af1b8c3 --project=services-provider-b9462 > android/app/google-services.json
> firebase apps:sdkconfig IOS 1:138471737210:ios:30c53370e1a44fadf1b8c3 --project=services-provider-b9462 > ios/Runner/GoogleService-Info.plist
> ```

This will:

- Create/select your Firebase project
- Register Android (`com.example.flutter_bloc`) and iOS (`com.example.flutterBloc`) apps if missing
- Write `android/app/google-services.json`
- Write `ios/Runner/GoogleService-Info.plist`
- Overwrite `lib/firebase_options.dart` with real values

**No `.env` Firebase keys are needed** — config lives in the generated files above.

## 3. iOS: Push capability + APNs

In Xcode → Runner target:

1. Signing & Capabilities → add **Push Notifications**
2. Firebase Console → Project Settings → Cloud Messaging → upload your **APNs auth key** (.p8)

Then:

```bash
cd ios && pod install && cd ..
```

## 4. Apply Supabase migration

```bash
cd App/supabase
supabase db push
```

Or run `App/supabase/migrations/20240626000007_device_tokens.sql` in the SQL Editor.

## 5. Enable server-side push (required for notifications to send)

In Firebase Console → Project settings → **Service accounts** → **Generate new private key**.

Add to Vercel env (and `App/admin/.env.local` for local dev):

```
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
```

Paste the **entire JSON on one line**.

The API sends push notifications when:
- Admin changes booking status → customer **and** provider notified
- Provider changes booking status → customer notified
- Chat message sent → other party notified

Tap notification:
- Chat → opens chat screen for that booking
- Booking status → opens orders tab (or chat if status is accepted/in progress/completed)

## 6. Redeploy Vercel API

Push to GitHub so push handlers and token routes are live.

## 7. Run the app

```bash
flutter pub get
flutter run
```

On login, the app registers the FCM token with your backend. Look for `[FCM] Token registered with backend` in debug logs.

## CI / headless (optional)

```bash
firebase login:ci          # copy token
flutterfire configure --token=<token> --project=<project-id> ...
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `[FCM] Disabled — run flutterfire configure` | Complete steps 1–2 |
| Android build: missing google-services.json | Run `flutterfire configure` |
| iOS no FCM token | Push capability + APNs key in Firebase |
| Token not saved on server | Run Supabase migration + redeploy Vercel |
