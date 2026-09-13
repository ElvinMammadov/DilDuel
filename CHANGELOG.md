# Changelog

All notable changes to DilDuel are documented here.

---

## [Unreleased] — Firebase Auth & Cloud Sync

### Added

#### Authentication (`lib/features/auth/`)
- New `auth` feature following the existing **library + `part of`** pattern.
- `AuthUser` — lightweight domain model holding `uid`, `email`, and
  `displayName`; decoupled from the Firebase SDK.
- `AuthRepository` (abstract) — contract with `authStateChanges` stream,
  `currentUser`, `signInWithGoogle()`, `signInWithApple()`,
  `signInWithEmailAndPassword()`, `registerWithEmailAndPassword()`,
  `sendPasswordResetEmail()`, and `signOut()`.
- `FirebaseAuthRepository` — implementation backed by `firebase_auth`,
  `google_sign_in`, and `sign_in_with_apple`.
- `AuthCubit` / `AuthState` — Cubit that exposes
  `unauthenticated | loading | authenticated | error` states and drives
  sign-in/sign-out flows.
- `SignInScreen` — email/password sign-in + Google + Apple social buttons.
- `RegisterScreen` — new account creation with email/password.
- Both screens use `AppElevatedButton`, `AppTheme` constants, and
  `easy_localization` keys for full i18n support.

#### Repository layer (`lib/core/data/repositories/`)
- **`BookmarkRepository`** (abstract) — unified contract for bookmarks
  *and* unknown-word persistence; decouples all callers from SQLite or
  Firestore specifics.
- **`LocalBookmarkRepository`** — implementation backed by the existing
  SQLite `DBHelper`.
- **`FirestoreBookmarkRepository`** — implementation backed by Cloud
  Firestore at `users/{uid}/bookmarks` and `users/{uid}/unknownWords`.
- **`SyncBookmarkRepository`** (`@LazySingleton`) — composite repository:
  reads always come from local SQLite (fast, offline-capable); writes go
  to SQLite immediately and to Firestore in the background when signed in.
  On sign-in it performs a bidirectional merge so data from other devices
  appears locally and local-only items are pushed to the cloud.
- **`TrainingProgressRepository`** (abstract) — contract for persisting
  per-level word position and the last accessed level.
- **`LocalTrainingProgressRepository`** — SQLite-backed implementation
  (thin wrapper around existing `DBHelper` helpers).
- **`SyncTrainingProgressRepository`** — composite that mirrors the same
  local-first / Firestore-background pattern as the bookmark repo.
- **`FirestoreTrainingProgressRepository`** — Firestore-backed
  implementation at `users/{uid}/trainingProgress`.

#### Firebase / platform setup
- `firebase_options.dart` — generated Firebase project config (dev +
  prod environments via `mains/`).
- `android/app/google-services.json` — Android Firebase config.
- `ios/Runner/GoogleService-Info.plist` — iOS Firebase config.
- `ios/Runner/Runner.entitlements` — Sign-in-with-Apple entitlement.
- `ios/Runner/Info.plist` — added `CFBundleURLTypes` for Google Sign-In
  redirect and `NSCameraUsageDescription` placeholder.

#### New dependencies (`pubspec.yaml`)
| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | `^3.6.0` | Firebase initialization |
| `firebase_auth` | `^5.3.1` | Authentication |
| `cloud_firestore` | `^5.4.4` | Cloud data sync |
| `google_sign_in` | `^6.2.1` | Google OAuth |
| `sign_in_with_apple` | `^6.1.2` | Apple Sign-In (iOS) |

### Changed

#### Settings screen (`lib/features/settings/`)
- Added **account section**: shows current user avatar / email when signed
  in, and a sign-in entry point when signed out.
- Sign-out triggers `AuthCubit.signOut()` which clears both local and
  remote session state.

#### Bookmarks feature (`lib/features/bookmarks/`)
- `BookmarksBloc` now depends on the abstract `BookmarkRepository`
  interface instead of `DBHelper` directly — no user-facing behaviour
  change; wires up automatically via DI to `SyncBookmarkRepository`.

#### Training feature (`lib/features/training/`)
- `TrainingCubit` now depends on `TrainingProgressRepository` instead of
  `DBHelper` directly — same offline behaviour, but progress is synced to
  Firestore when signed in.

#### DI (`lib/core/di/dependency_injection.config.dart`)
- Auto-generated bindings updated for all new repositories and
  `AuthCubit`; no manual wiring required.

#### Entry points (`lib/mains/`)
- Both `dev/main.dart` and `prod/main.dart` initialize `Firebase` before
  `runApp` and provide `AuthCubit` at the widget-tree root.

### Architecture notes

The new repository layout follows the same **abstract interface → local →
remote → sync composite** pattern used by the existing quiz/search layers:

```
core/data/repositories/
├── bookmark_repository.dart           # abstract interface
├── training_progress_repository.dart  # abstract interface
├── local/
│   ├── local_bookmark_repository.dart
│   └── local_training_progress_repository.dart
├── remote/
│   ├── firestore_bookmark_repository.dart
│   └── firestore_training_progress_repository.dart
├── sync_bookmark_repository.dart      # composite (registered as singleton)
└── sync_training_progress_repository.dart
```

The `auth` feature is a **self-contained library** (`library auth;`) whose
barrel file (`auth.dart`) `part`s in all sub-files, keeping consistent with
every other feature in the project.

---

## Earlier releases

See git log for changes prior to Firebase integration.