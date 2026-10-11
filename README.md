# Dil Duel

A German-Azerbaijani dictionary app built with Flutter. Supports bidirectional translation (De→Az and Az→De), vocabulary quizzes, bookmarks, and text-to-speech — all offline using a bundled SQLite database.

## Features

- **Search** — instant word lookup in both directions (German→Azerbaijani, Azerbaijani→German)
- **Bookmarks** — save words for later reference, synced to the cloud when signed in
- **Quiz** — vocabulary quiz with configurable question count (4–10 words), multiple-choice format
- **Training** — practice mode for reviewing words, progress synced to the cloud when signed in
- **Authentication** — sign in with Google, Apple, or email/password via Firebase Auth
- **Cloud sync** — bookmarks and training progress synced across devices via Cloud Firestore
- **Text-to-speech** — listen to pronunciation of words
- **Speech-to-text** — search by voice
- **Themes** — light, dark, and system-default
- **Localization** — UI available in Azerbaijani and German
- **Offline-first** — all dictionary data is bundled locally; auth and sync are optional
- **Ads** — an AdMob banner above the bottom navigation, shown only after consent where the law requires it (see [Advertising](#advertising))

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart SDK `>=3.4.1`) |
| State management | flutter_bloc (BLoC + Cubit) |
| Dependency injection | get_it + injectable |
| Local database | sqflite (SQLite) |
| Cloud database | Cloud Firestore |
| Authentication | Firebase Auth, Google Sign-In, Sign-in with Apple |
| Navigation | MaterialApp named routes |
| Localization | easy_localization |
| Functional programming | dartz |
| Text-to-speech | flutter_tts |
| Speech-to-text | speech_to_text |
| Persistence | shared_preferences |

## Architecture

Clean Architecture with feature-first folder structure:

```
lib/
├── core/
│   ├── components/       # Shared UI components (buttons, cards)
│   ├── constants/        # App-wide constants
│   ├── data/
│   │   ├── data_sources/ # SQLite data sources
│   │   └── repositories/ # Abstract interfaces + local/remote/sync impls
│   ├── di/               # Dependency injection setup
│   ├── error/            # Exceptions and failures
│   ├── state/            # App-level cubits (theme, app state)
│   ├── theme/            # Light and dark themes
│   └── utils/            # Helpers (dimensions, sizes, snackbar)
├── features/
│   ├── auth/             # Firebase Auth (Google, Apple, email/password)
│   ├── bookmarks/        # Save and manage bookmarked words
│   ├── home/             # Shell/navigation host
│   ├── quiz/             # Vocabulary quiz (BLoC + domain + data layers)
│   ├── search/           # Word search (BLoC + domain + data layers)
│   ├── settings/         # Theme, language, and account preferences
│   ├── shared/           # Widgets shared across features
│   ├── training/         # Training/practice mode
│   └── word_list/        # Full word list browsing
├── firebase_options.dart  # Firebase project configuration
└── mains/
    ├── dev/main.dart     # Development entry point
    └── prod/main.dart    # Production entry point
```

Each feature follows Clean Architecture layers:

```
feature/
├── data/
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Pure data models
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic
└── presentation/
    ├── bloc/            # BLoC / state management
    ├── screens/         # Screen widgets
    └── widgets/         # Feature-local widgets
```

Cross-cutting data repositories live in `core/data/repositories/` and follow
a **local → remote → sync composite** pattern:

```
core/data/repositories/
├── bookmark_repository.dart           # abstract interface
├── training_progress_repository.dart  # abstract interface
├── local/                             # SQLite implementations
├── remote/                            # Firestore implementations
└── sync_*.dart                        # composites (registered as singletons)
```

Reads always go to local SQLite for speed and offline reliability; writes go
to SQLite immediately and to Firestore in the background when a user is signed
in. On sign-in a bidirectional merge reconciles local and cloud data.

## Getting Started

### Prerequisites

- Flutter SDK `>=3.4.1`
- Dart SDK `>=3.4.1 <4.0.0`

### Setup

```sh
# Install dependencies
flutter pub get

# Generate DI code
dart run build_runner build --delete-conflicting-outputs
```

### Run

```sh
# Development
flutter run --target lib/mains/dev/main.dart

# Production
flutter run --target lib/mains/prod/main.dart
```

### Build

```sh
# Android APK
flutter build apk --target lib/mains/prod/main.dart

# iOS
flutter build ios --target lib/mains/prod/main.dart
```

## Supported Languages

| Language | Locale |
|---|---|
| Azerbaijani | `az` |
| German | `de` |

Translation files live in `assets/translations/`.

## Advertising

An adaptive AdMob banner sits above the bottom navigation (`lib/core/ads/`). It is shown on Search, Bookmarks, the Quiz tab's card list and results, and the Training level cards. It is hidden during training flashcards and quiz or listening tests, where swipes and answer buttons risk accidental taps. `AdsCubit` (`lib/core/state/`) decides when.

**Consent.** `AdsCubit.init()` runs on the first frame of `HomeShell`. It uses Google's User Messaging Platform to ask for consent where required (EEA, UK), plus Apple's tracking prompt on iOS, and starts the ads SDK only if ads may be requested. In regions where it applies, Settings shows *Privacy options for ads* so users can change their choice. The privacy policy (`scripts/build_site.py`) describes this.

**Before release**
- Android uses the real AdMob app ID (`AndroidManifest.xml`). iOS uses its real AdMob app ID too (`ios/Runner/Info.plist`).
- The banner ad units for both platforms are the defaults in `lib/core/ads/ad_unit_ids.dart`; `--dart-define=ADMOB_BANNER_ANDROID=...` / `ADMOB_BANNER_IOS=...` override them. Every debug build uses Google's test unit.
- In AdMob, *Privacy & messaging*, publish a GDPR message and, for iOS, an IDFA explainer message; update the store privacy forms.

**Testing consent.** Run a debug build with `--dart-define=ADS_DEBUG_EEA=true` to make a simulator or emulator appear to be in the EEA. A physical device must also be added as a test device (`ConsentDebugSettings.testIdentifiers`).

## Dictionary Data

The dictionary database (`assets/luget.db`) is bundled with the app and loaded at startup via `sqflite`. No network connection is needed. The database supports two translation directions set via `dicType`:

- `AzDe` — Azerbaijani to German
- `DeAz` — German to Azerbaijani

### Sources and credits

The dictionary data is based on the German–Azerbaijani dictionary *Alman – Azərbaycanca lüğət* (A1–B2), compiled by Ramil Səfiyev. This credit is also shown in the app (Settings → About app) and on the website.

### CEFR levels

Every `DeAz` word has a `level` from A1 to C2:

- **A1, A2, B1** come from the official Goethe-Institut word lists (Start Deutsch 1 / Fit in Deutsch 1, Goethe-Zertifikat A2 and B1). A word gets the earliest level whose list contains it.
- **B2, C1, C2** are estimates. Goethe publishes no lists above B1, so words missing from all three lists are split by word frequency (`wordfreq`).

`scripts/assign_goethe_levels.py` regenerates the levels. The Goethe PDFs are copyrighted and not stored in the repo; download them from goethe.de and pass their paths (see the script's docstring). When the levels change, bump `dbVersion` in `word_local_data_source_impl.dart` to match the script's `DB_VERSION`; existing installs are then migrated in place without losing user data.