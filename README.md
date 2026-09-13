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

## Dictionary Data

The dictionary database (`assets/luget.db`) is bundled with the app and loaded at startup via `sqflite`. No network connection is needed. The database supports two translation directions set via `dicType`:

- `AzDe` — Azerbaijani to German
- `DeAz` — German to Azerbaijani