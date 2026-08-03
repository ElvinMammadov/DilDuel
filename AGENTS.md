# AGENTS.md

## Project Overview
- Flutter dictionary app (`AzDe` <-> `DeAz`) with offline SQLite data (`assets/luget.db`) and 4 tabs: Search, Bookmarks, Quiz, Training.
- App startup is in `lib/mains/dev/main.dart` and `lib/mains/prod/main.dart`; both initialize localization, DI, and DB before `runApp`.
- Existing docs are minimal (`README.md` is Flutter template), so rely on code-first discovery.

## Inspect-First Files
- Entry + composition: `lib/mains/dev/main.dart`, `lib/features/home/home.dart`, `lib/features/widgets/app_bar.dart`.
- DI graph: `lib/core/di/dependency_injection.dart`, generated `lib/core/di/dependency_injection.config.dart`.
- Local storage boundary: `lib/core/data/data_sources/local/word_local_data_source_impl.dart` (`DBHelper`).
- Feature barrels using `part of`: `lib/features/search/search.dart`, `lib/features/bookmarks/bookmarks.dart`, `lib/features/quiz/quiz.dart`, `lib/features/settings/settings.dart`, `lib/features/training/training.dart`.
- Shared word detail: `lib/features/shared/widgets/word_bottom_sheet.dart` — used by both Search and Bookmarks; call via `showWordBottomSheet(context, word, locale)`.
- Typography: `lib/core/theme/app_text_styles.dart` (`AppTextStyles` — Plus Jakarta Sans + Source Serif 4 via `google_fonts`).

## Architecture And Data Flow
- State is mixed: global app/theme via Cubits (`AppCubit`, `ThemeCubit`), feature state via Cubits (`SearchBloc`, `BookmarksBloc`, `QuizBloc`).
- Search flow: UI -> `SearchBloc.search` -> `SearchWord` use case -> `WordRepositoryImpl` -> `WordLocalDataSource.searchWords`.
- Bookmarks bypass repository and call `DBHelper` static methods directly from `BookmarksBloc`. Quiz word fetching goes through `QuizBloc` -> `QuizRepository` -> `WordLocalDataSource`; quiz results are still saved via `DBHelper.insertQuizResult()` directly from `QuizBloc`.
- Dictionary direction is centralized in `AppCubit`/`AppState` (`DictionaryType.azDe` value `123`, `deAz` value `321`) and drives DB table (`AzDe`/`DeAz`) + speech locale.

## Code Conventions Specific To This Repo
- Use package imports only (`analysis_options.yaml` enables `always_use_package_imports` and warns on relative imports).
- Many features use library `part` files; when adding files under Search/Quiz/Bookmarks/Settings, update the feature barrel `part` list.
- Localization uses `easy_localization` with key access like `'quiz.title'.tr()` and assets in `assets/translations/az.json`, `assets/translations/de.json`.
- Shared UI constants/components live in `lib/core/theme/app_theme.dart`, `lib/core/utils/dimensions.dart`, and `lib/core/components/*`.
- Navigation is mostly imperative (`Navigator.pushNamed('/settings')`); `go_router` is only used in `features/shared/widgets/custom_dialog.dart` for `context.pop()`.
- Typography: always use `AppTextStyles.<method>(color)` from `lib/core/theme/app_text_styles.dart`; never construct raw `TextStyle` for display text.
- Error handling: repositories return `Either<Failure, T>` (from `dartz`); define failure types in `lib/core/error/failures.dart`.
- `avoid_void_async` is enforced as an **error** — async functions must declare `Future<void>`, never bare `void`.
- `always_declare_return_types` is enforced — all methods and top-level functions must have explicit return types.
- Shared word detail bottom sheet: call `showWordBottomSheet(context, word, locale)` from `lib/features/shared/widgets/word_bottom_sheet.dart`; do not inline `showModalBottomSheet` for word details.

## Critical Workflows
- Install deps: `flutter pub get`.
- Run dev entrypoint: `flutter run -t lib/mains/dev/main.dart`.
- Run prod entrypoint: `flutter run -t lib/mains/prod/main.dart`.
- Regenerate DI after changing `@injectable`/`@module`: `dart run build_runner build --delete-conflicting-outputs`.
- Static checks: `flutter analyze`.
- Tests currently need modernization; `test/widget_test.dart` is default counter test and does not match current UI.

## Integration Notes And Gotchas
- `DBHelper.initDB()` copies `assets/luget.db` into app documents directory on first run; quiz table `quiz_results` is ensured in `onCreate`, `onUpgrade`, and `onOpen`.
- Speech integration: `speech_to_text` in `SearchSection` and `flutter_tts` in search bottom sheet; locale switches by dictionary direction (`az-AZ` vs `de-DE`).
- Theme preference persistence is via `SharedPreferences` in `ThemeCubit` (`app_theme` key).
- Placeholder Training and some Settings actions are TODOs (`features/training`, multiple TODO handlers in `settings_screen.dart`).
- `GrammarTypeTranslator` in `lib/core/utils/grammar_type_translator.dart` maps German grammar labels to Azerbaijani and handles known DB typos (e.g. `'Prposition'` → `'sözönü'`).
- `package_info_plus` is used in Settings to display the app version; access via `PackageInfo.fromPlatform()`.

