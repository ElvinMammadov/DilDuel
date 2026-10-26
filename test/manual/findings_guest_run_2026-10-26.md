# Guest-mode test run — findings (2026-10-26)

- Build: debug, `lib/mains/dev/main.dart`, version 1.0.1
- Device: iPhone 17 Pro simulator, iOS 26.5, guest (not signed in)
- Driven with Maestro flows plus direct SQLite checks of `assets/luget.db` and the
  simulator app database. Cases refer to `manual_test_cases.md`.
- "Verified" means reproduced in the running app. "Likely cause" means read from the
  code but not confirmed by a debugger.

## Defects

### P1 — functional

**F-01 Search misses words that start with a capital non-ASCII letter**
(SRCH-08, SRCH-09)
- Repro: De→Az, search `übel`. Az→De, search `çin`, `özbəkistan`, `əfqanıstan`.
- Actual: `übel` returns *grübeln, übel, übelnehmen* but not *das Übel*. `çin` does not
  return *Çin*; `əfqanıstan` returns 0 rows although *Əfqanıstan* exists.
- Why: `searchWords` lower-cases the query in Dart, but the SQL uses `LOWER(key)` and
  SQLite lower-cases only ASCII, so `Ü Ö Ä Ə İ Ç Ş Ğ` stay upper-case in the DB side.
- Scope: 93 German keys contain `Ä/Ö/Ü`, and 30 Azerbaijani keys contain
  `Ə İ Ö Ü Ç Ş Ğ`. Country names (Çin, Özbəkistan, İngiltərə, İraq) are affected.
- File: `lib/core/data/data_sources/local/word_local_data_source_impl.dart:562`.

**F-02 The exact match is not ranked first for nouns**
(SRCH-05)
- Repro: De→Az, search `haus`.
- Actual: `das Haus` is the 10th result, behind *haushalten* and nine other `das …haus`
  compounds.
- Why: noun keys include their article (`das Haus`), so the `'haus%'` prefix rule never
  matches nouns. They all fall into the "contains" group, sorted by `key ASC`.
- Same file and query as F-01.

**F-03 "Geri al" (Undo) after removing a bookmark does nothing**
(BKM-07)
- Repro: Bookmarks → Seçilmişlər → swipe an item left → tap "Geri al".
- Actual: reproduced 3 times. The item is not restored, and the `bookmark` table stays
  empty (checked in the DB). The snackbar also stays on screen after the tap, because
  the action does not dismiss it.
- Likely cause: the undo closure in `bookmarks_screen.dart` calls `context.read` with
  the list row's own `BuildContext`, and that row is already removed from the tree.
  I could not capture an exception, so confirm this when fixing.

**F-04 Switching the language live leaves part of the UI in the old language**
(SET-03, SET-06)
- Repro: Settings → Language → Deutsch → Confirm.
- Actual:
  - the "language changed" snackbar is shown in Azerbaijani ("Dil dəyişdirildi");
  - screens that were already built keep some old strings: Training headings
    ("Səviyyələr", "Gündəlik mövzular"), the back-bar label on Bookmarks
    ("Seçilmişlər") and on Results ("Nəticələr"), and the Results segmented control
    ("Tərcümə / Dinləmə").
  - A cold restart shows everything in German.
- Likely cause: `context.setLocale(...)` is not awaited in `language_bottom_sheet.dart`
  (`_apply`) and the snackbar text is read right after. Widgets kept alive by the
  `IndexedStack` do not rebuild when only `.tr()` strings change.

### P2 — inconsistency, polish

**F-05 Training progress ring and text disagree**
- A fresh deck shows "1%" next to "0 / 137" (*Ailə və münasibətlər*) and "1%" next to
  "0 / 139" (*Geyim*). Jumping to the last word of A1 shows "100%" next to
  "1070 / 1071".
- Why: `training_level_selector.dart:123` uses `(saved + 1) / total` for the ring, but
  the label prints `saved / total`. Inside a deck the counter is 1-based ("1 / 1071").

**F-06 Listening history rows are labelled "Test #n" / "Quiz #n"**
- `listening.results.session_number` ("Sessiya #{}" / "Sitzung #{}") exists in both
  translation files but is never used. `results_tab.dart` always uses
  `quiz.results.quiz_number`. (`manual_test_cases.md` LST-08 and RES-04 expect
  "Sessiya #n".)

**F-07 Result dates are not localized**
- "Oct 26, 2026 01:59" is shown in the Azerbaijani and German UI. `results_tab.dart:49`
  and `:186` call `DateFormat(...)` without a locale.

**F-08 Long compound nouns break mid-word in the word sheet header**
- `das Einfamilienhaus` shows as "Einfamilienh / aus", because the three action buttons
  take the width next to the title.

**F-09 Bookmark list shows the article in the snackbar; the word sheet does not**
- Removing *das Einfamilienhaus* shows "das Einfamilienhaus … silindi", while adding it
  showed "Einfamilienhaus". Items loaded from the `bookmark` table have no `article`
  field, so the "bare word" logic never strips it.
- Swiping left is the only way to remove an item and nothing hints at it.

**F-10 Database migrations fail on every launch**
- The log shows `ALTER TABLE ... ADD COLUMN word_id` (twice) and
  `ADD COLUMN plural` failing with "duplicate column name" at each start. They are
  caught, so there is no user impact, but there is no schema check or version bump.

**F-11 Keyboard handling on Search**
- After closing a word sheet the search field regains focus and the keyboard covers the
  bottom tab bar, so the user has to dismiss it before switching tabs.

**F-12 Gender labels mix languages**
- The word sheet and training cards show "Masculine (Kişi)" and "Neuter (Orta cins)":
  English words in a German/Azerbaijani UI, and "Kişi" means "man", not
  "masculine gender".

### Notes (not defects)

- **Voice search** (SRCH-32): the README promises it; the search bar has no microphone
  and nothing in `lib/` implements it.
- **Listening quiz** draws from all 17,733 German words, so beginners get words like
  *die Halswirbelsäule*. The direction switcher is shown on that screen but has no
  effect.
- A swipe slower than about 400 px/s does not change the training card (the
  `onHorizontalDragEnd` velocity threshold); the İrəli/Geri buttons always work.

## Passed in this run

- Launch, default direction De→Az, Google test banner (consent granted in debug).
- Search: prefix-before-contains order, upper/lower case for ASCII, not-found state,
  clear button, direction switch with snackbar, recent searches saved only on tap and
  kept after restart.
- Word sheet (De→Az and Az→De): article chip, grammar, examples, bookmark and
  "unknown" toggles with correct snackbars.
- Bookmarks: category counts, list, swipe-to-remove (except undo, F-03).
- Training: deck totals (levels add up to 17,733), first/last card boundaries, İrəli
  disabled on the last card, jump sheet, progress and last deck restored after restart.
- Translation quiz and Listening quiz: 10 questions, correct/wrong colours, score bands,
  results saved with correct counts and average.
- Settings: guest profile card, language, theme (light/dark/system sheet, dark applied
  immediately), FAQ (13 items), feedback form validation, sign-in form validation.
- German UI after a cold restart is complete and consistent.

## Not covered (needs you or another setup)

- Google and Apple sign-in, real email account, guest-data merge dialog and cloud sync.
- Sending real feedback (would write to Firestore), delete account.
- Audible speech quality, offline mode, Android device, iPad, rotation, large text,
  VoiceOver, upgrade from an older build.

## State left on the simulator

- App language is German, theme is Dark, and the database has 1 "unknown" word and
  the A1 training position at the last word. Reset in Settings or reinstall the app.

## Fix status (2026-10-26, same day)

All twelve findings plus one found while fixing (F-13) are fixed and were
re-checked in the running app on the iPhone 17 Pro simulator. Unit and widget
tests were added for each; `flutter test` (123 tests) and `flutter analyze lib test`
pass.

| ID | Fix | Checked on device |
|----|-----|-------------------|
| F-01 | Search folds `Ä Ö Ü Ə Ç Ş Ğ İ` in SQL and in Dart | `übel` finds *das Übel*; `çin` lists *Çin*; `ingiltərə` finds *İngiltərə* |
| F-02 | Ranking ignores a leading der/die/das; exact match first | `haus` lists *das Haus* first |
| F-03 | Undo uses the `BookmarksBloc` captured before the row is removed; the snackbar action also dismisses it | Swipe, "Rückgängig": row restored (DB 0 → 1), snackbar closed |
| F-04 | `setLocale` is awaited, then every element is rebuilt | German → Azerbaijani: snackbar, Settings, Bookmarks, Training all switch at once |
| F-05 | Ring uses `saved / total` | "0%" next to "3 / 1071" and "0 / 565" |
| F-06 | Listening rows use `listening.results.session_number` | "Sessiya #1" |
| F-07 | `DateFormat` gets the app locale; `initializeDateFormatting()` in both entrypoints; `intl` is now a direct dependency | "okt 26, 2026 02:02" in the Azerbaijani UI |
| F-08 | Chip and buttons share a row; a single long word scales down instead of breaking | *Einfamilienhaus* on one line |
| F-09 | Shared `bareWord(Word)` also strips der/die/das from bookmark rows | Snackbar shows "Einfamilienhaus" |
| F-10 | `addColumnIfMissing` checks `PRAGMA table_info` first | 0 "DB Error" lines at launch (was 3) |
| F-11 | Search field is unfocused before the sheet opens | No keyboard after closing the sheet |
| F-12 | Gender is shown as the German term; Azerbaijani gloss is "kişi / qadın cinsi", "orta cins" | "Substantiv (isim) · Neutrum (orta cins)" |
| F-13 | Saved-word lookups no longer use `UPPER(key)` (ASCII only); they use `key = ? COLLATE NOCASE` | Bookmark *İngiltərə* is listed, counted and removed |

**F-13 (new):** bookmarks, unknown words and listened words whose key contains a
non-ASCII letter (`ə ü ö ş ç ğ İ`) could not be found again. They vanished from
the list, could not be removed, and showed as not bookmarked. This affected a large
share of Azerbaijani words. Found while checking F-03.

Open observation, not reproduced: once the A1 training position read 0 after I had
left it at the last word. Position then saved and survived a restart correctly
(0 → 3 → 3), so I could not tie it to a code defect.

