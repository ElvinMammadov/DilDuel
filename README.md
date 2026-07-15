# Dil Duel

A German-Azerbaijani dictionary app built with Flutter. Supports bidirectional translation (De→Az and Az→De), vocabulary quizzes, bookmarks, and text-to-speech — all offline using a bundled SQLite database.

## Features

- **Search** — instant word lookup in both directions (German→Azerbaijani, Azerbaijani→German)
- **Bookmarks** — save words for later reference
- **Quiz** — vocabulary quiz with configurable question count (4–10 words), multiple-choice format
- **Training** — practice mode for reviewing words
- **Text-to-speech** — listen to pronunciation of words
- **Speech-to-text** — search by voice
- **Themes** — light, dark, and system-default
- **Localization** — UI available in Azerbaijani and German
- **Offline-first** — all dictionary data is bundled locally (no internet required)

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart SDK `>=3.4.1`) |
| State management | flutter_bloc (BLoC + Cubit) |
| Dependency injection | get_it + injectable |
| Local database | sqflite (SQLite) |
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
│   ├── data/             # Local data sources (SQLite)
│   ├── di/               # Dependency injection setup
│   ├── error/            # Exceptions and failures
│   ├── state/            # App-level cubits (theme, app state)
│   ├── theme/            # Light and dark themes
│   └── utils/            # Helpers (dimensions, sizes, snackbar)
├── features/
│   ├── bookmarks/        # Save and manage bookmarked words
│   ├── home/             # Shell/navigation host
│   ├── quiz/             # Vocabulary quiz (BLoC + domain + data layers)
│   ├── search/           # Word search (BLoC + domain + data layers)
│   ├── settings/         # Theme and language preferences
│   ├── training/         # Training/practice mode
│   └── word_list/        # Full word list browsing
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