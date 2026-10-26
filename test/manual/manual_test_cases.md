# DilDuel — Manual Test Cases

Baseline test suite for manual testing. It is also the source list for later
unit, widget and E2E automation: each case has an **Auto** tag saying where it
should end up.

- App: DilDuel (`flutter_dic`), version in `pubspec.yaml`
- Entrypoints: `lib/mains/dev/main.dart` (dev), `lib/mains/prod/main.dart` (prod)
- Written from the code as of branch `dev`. Where the expected result is a
  guess or the code and docs disagree, the case is marked **VERIFY** and listed
  in [Open questions](#open-questions-found-while-writing-this).

## How to use

1. Pick a build and device from [Test environment](#test-environment).
2. Run the [Smoke suite](#1-smoke-suite) first. If it fails, stop and report.
3. Run the module suites. Fill in **Result** with `P` (pass), `F` (fail),
   `B` (blocked) or `N/A`. Log every `F` with its case ID.
4. Record the run in [Run log](#run-log).

### Priority

| Pri | Meaning |
|-----|---------|
| P0 | Core flow. A failure blocks release. |
| P1 | Important feature or common edge case. |
| P2 | Minor, cosmetic or rare. |

### Auto tags

| Tag | Meaning |
|-----|---------|
| U | Unit test (Cubit, repository, utility) |
| W | Widget test |
| E | E2E / integration test on a device or emulator |
| M | Manual only (hardware, store, third-party UI, visual judgement) |

## Test environment

| Item | Minimum coverage |
|------|------------------|
| Android | One small phone (≤ 5.5") and one large phone, Android 8+ and latest |
| iOS | One small iPhone (SE size) and one current iPhone, iOS 15+ and latest |
| Languages | App language Azerbaijani (`az`) and German (`de`) |
| Themes | Light, Dark, System |
| Network | Online, Offline (airplane mode), Flaky (toggle during an action) |
| Accounts | Guest, email account A, email account B, Google account, Apple account (iOS) |
| Text size | Default and largest system font size |

### Test data to prepare

| Item | Use |
|------|-----|
| German word with article `der`, one `die`, one `das` | Article colours, grammar block |
| German verb with Imperfekt and Perfekt | Grammar block |
| German adjective with Komparativ and Superlativ | Grammar block |
| German noun with Genitiv and Plural | Grammar block |
| Word with an example and a sentence | Example block |
| Word that has several numbered Azerbaijani translations | Az→De chips, quiz first translation |
| Word containing `ä ö ü ß` and Azerbaijani word containing `ə ı ö ü ş ç ğ` | Special-character search |
| A string that is in no dictionary (e.g. `qwertzuiop`) | Not found state |
| Email account A with ≥ 3 bookmarks, 2 unknown words, 2 quiz results, training progress in A1 | Sync tests |
| Email account B (empty) | Account switching |

### Preconditions used in the tables

- **Fresh install**: app installed, never opened, guest, default language.
- **Guest**: signed out.
- **Signed in**: signed in as account A unless stated.
- **Dictionary direction** is shown as De→Az (app default) or Az→De.

---

## 1. Smoke suite

Run on every build. All P0.

| ID | Title | Steps | Expected | Auto | Result |
|----|-------|-------|----------|------|--------|
| SM-01 | App launches | Fresh install, open app | Home opens on the Search tab, no crash, no blank screen | E | |
| SM-02 | Search finds a word | Type a common German word | Matching word cards appear | E | |
| SM-03 | Word detail opens | Tap a result | Bottom sheet shows translation and grammar | E | |
| SM-04 | Bookmark a word | In the sheet tap the bookmark icon, open Bookmarks tab → Bookmarks | Word is listed | E | |
| SM-05 | Training works | Training tab → A1 → swipe to next card | Card changes, counter increases | E | |
| SM-06 | Quiz completes | Quiz tab → Translation → start → answer all questions | Result screen with a score | E | |
| SM-07 | Listening works | Quiz tab → Listening → start → answer a question | Word is spoken, answer is evaluated | M | |
| SM-08 | Settings open | Tap the gear icon | Settings screen opens | E | |
| SM-09 | Language switch | Settings → Language → choose Deutsch | UI language changes immediately | E | |
| SM-10 | Sign in | Settings → Sign in with email | Signed-in profile card is shown | E | |

---

## 2. App shell and navigation (NAV)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| NAV-01 | Four tabs present | P0 | Open app | Bottom bar shows Search, Training, Quiz, Bookmarks (labels in current language) | W | |
| NAV-02 | Default tab | P0 | Cold start | Search tab is selected | W | |
| NAV-03 | Switch tabs | P0 | Tap each tab | Content changes, selected tab is highlighted with filled icon | W | |
| NAV-04 | Tab state is kept | P1 | Search a word, go to Training, return to Search | Search text and results are still there (IndexedStack) | W | |
| NAV-05 | Tapping the active tab | P2 | Tap the selected tab again | Nothing happens, no reload, no flicker | W | |
| NAV-06 | Bookmarks refresh on entry | P1 | Bookmark a word from Search, switch to Bookmarks | New word appears without manual refresh | E | |
| NAV-07 | Direction switcher visibility | P1 | Visit each tab | Az→De / De→Az switcher is shown on Search and Quiz only; Training and Bookmarks show only the gear | W | |
| NAV-08 | Title in app bar | P2 | Look at the home app bar | Shows "Dil Duel" on all tabs | W | |
| NAV-09 | Settings navigation | P0 | Tap gear, then the back arrow | Settings opens; back returns to the same tab and state | W | |
| NAV-10 | Android back button on Home | P1 | Press system back on any tab | App closes or backgrounds (no crash, no blank route) | M | |
| NAV-11 | Rotation | P2 | Rotate device on each tab (if rotation is allowed) | Layout does not overflow; state is kept | M | |

---

## 3. Dictionary search (SRCH)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| SRCH-01 | Initial empty state | P1 | Open Search with no recent searches | "Söz axtarmağa başlayın" empty state with description | W | |
| SRCH-02 | Search as you type | P0 | Type `haus` | Results update on every keystroke, loader shown briefly | W | |
| SRCH-03 | De→Az result card | P0 | Search a German word (direction De→Az) | Card shows German key and Azerbaijani meaning (max 2 lines, ellipsis) | W | |
| SRCH-04 | Az→De result card | P0 | Switch to Az→De, search an Azerbaijani word | Card shows key and German translations as chips; numbered translations are split into separate chips | W | |
| SRCH-05 | Prefix matches first | P1 | Search `ha` | Words starting with `ha` are listed before words that only contain it, each group alphabetical | U | |
| SRCH-06 | Contains match | P1 | Search `aus` | Words containing `aus` anywhere are returned | U | |
| SRCH-07 | Case-insensitive | P0 | Search `HAUS`, `haus`, `Haus` | Same results | U | |
| SRCH-08 | German special chars | P1 | Search `ü`, `ä`, `ß` words; try upper case `Ü`/`Ä` | Words are found. **VERIFY** upper-case non-ASCII (SQLite `LOWER()` is ASCII-only) | U | |
| SRCH-09 | Azerbaijani special chars | P1 | In Az→De search `ə`, `ı`, `ş`, `ç`, `ğ`; try `İ`/`I`, `Ə` | Words are found. **VERIFY** upper-case `Ə` and `İ`/`ı` handling | U | |
| SRCH-10 | Not found | P0 | Search `qwertzuiop` | "`qwertzuiop` tapılmadı" title with "lüğətdə mövcud deyil" description | W | |
| SRCH-11 | Whitespace only | P1 | Type spaces only | No search is run; initial/recent view is shown, no crash | U | |
| SRCH-12 | Leading/trailing spaces | P1 | Search `  haus  ` | Behaviour is consistent and does not crash. **VERIFY** whether padded query finds `haus` | U | |
| SRCH-13 | Clear button | P0 | Type text, tap × in the field | Field empties, results clear, initial/recent state appears | W | |
| SRCH-14 | Clear button visibility | P2 | Empty the field manually | × disappears when the field is empty | W | |
| SRCH-15 | Fast typing and deleting | P1 | Type and delete characters quickly | Final list matches the final text; no stale results from an earlier query | E | |
| SRCH-16 | Very long input | P2 | Paste a 500-character string | No crash, "not found" shown | W | |
| SRCH-17 | Special characters | P2 | Search `%`, `_`, `'`, `"`, `\` | No crash. **VERIFY** `%` and `_` are not treated as wildcards (they are passed to SQL LIKE) | U | |
| SRCH-18 | Emoji / non-Latin input | P2 | Paste `😀` or Cyrillic text | No crash, "not found" shown | W | |
| SRCH-19 | Switch direction with text | P0 | Type a word, tap the Az→De switcher | Snackbar "Lüğət istiqaməti dəyişdirildi" + subtitle for the new direction; the same text is searched again in the new dictionary | W | |
| SRCH-20 | Switch direction with empty field | P1 | Clear the field, switch direction | Recent searches for the new direction are shown | W | |
| SRCH-21 | Default direction | P1 | Fresh install | Switcher reads `De → Az` | U | |
| SRCH-22 | Recent search saved on tap | P0 | Search `haus`, tap a result, close the sheet, clear the field | `haus` appears under "Son axtarışlar" | E | |
| SRCH-23 | Recent search not saved without tap | P1 | Search `haus`, do not tap a result, clear the field | `haus` is **not** in recent searches | E | |
| SRCH-24 | Recent search limit | P1 | Open 11 different results by 11 different queries | Only the 10 most recent are shown, newest first | U | |
| SRCH-25 | Recent search duplicates | P1 | Open results for the same query twice | Query appears once, moved to the top | U | |
| SRCH-26 | Recent searches per direction | P1 | Save a query in De→Az, switch to Az→De, clear field | Recent list shows only Az→De entries | U | |
| SRCH-27 | Tap a recent search | P0 | Tap an item in the recent list | Text field is filled and the search runs | W | |
| SRCH-28 | Persistence of recents | P1 | Save a recent search, kill and reopen the app | Recent searches are still there | E | |
| SRCH-29 | Recents wiped on sign-out | P1 | Signed in with recents → sign out → open Search with an empty field | Recent list is empty (previous account's list not shown) | E | |
| SRCH-30 | Keyboard behaviour | P2 | Scroll results while the keyboard is open | List scrolls; no overflow; keyboard handling is acceptable | M | |
| SRCH-31 | Search works offline | P0 | Airplane mode, search words | Results are returned (dictionary is local) | E | |
| SRCH-32 | Voice search | P1 | Look for a microphone control in the search bar (README says "You can also search by voice") | **VERIFY**: no voice search code was found in `lib/`. Either the README is wrong or the feature is missing | M | |
| SRCH-33 | Banner on Search | P1 | With ads consent granted, open Search | Banner is visible above the tab bar | M | |
| SRCH-34 | Large result list performance | P1 | Search a single letter (e.g. `a`) and scroll fast | List scrolls smoothly (lazy list); no jank or crash | M | |

---

## 4. Word detail sheet (WORD)

Opened from Search, Bookmarks and (for the pronunciation / bookmark actions) Training.

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| WORD-01 | Sheet opens | P0 | Tap a search result | Sheet slides up (30–85% of the screen height) | W | |
| WORD-02 | De→Az content | P0 | Open a noun | Header shows article chip + word, TƏRCÜMƏ block, QRAMMATİKA block, NÜMUNƏ block when data exists | W | |
| WORD-03 | Article colours | P1 | Open a `der`, `die`, `das` word | Blue / red / green chips respectively; no chip for words without an article | W | |
| WORD-04 | Noun grammar | P1 | Open a noun with Genitiv and Plural | Both forms are shown with correct labels | W | |
| WORD-05 | Verb grammar | P1 | Open a verb with Imperfekt/Perfekt | Both forms are shown | W | |
| WORD-06 | Adjective grammar | P1 | Open an adjective with Komparativ/Superlativ | Both forms are shown | W | |
| WORD-07 | Missing optional fields | P1 | Open a word without grammar/examples | Missing blocks are hidden, no empty headings, no "null" text | W | |
| WORD-08 | Examples | P1 | Open a word with `example` and `sentence` | "Qısa nümunə" and "Cümlə nümunəsi" appear correctly | W | |
| WORD-09 | Multiple translations | P1 | Open a word with numbered translations | Translations are listed in order, each readable, no clipping | W | |
| WORD-10 | Az→De content | P0 | Switch to Az→De, open a word | Shows German translations; grammar blocks that only exist for De→Az are not shown | W | |
| WORD-11 | Speak (De→Az) | P0 | Tap the speaker icon | German word is spoken aloud; icon animates while speaking | M | |
| WORD-12 | Stop speaking | P1 | Tap the speaker again while speaking | Speech stops, animation resets | M | |
| WORD-13 | Speech ends on its own | P1 | Let the speech finish | Animation stops automatically | M | |
| WORD-14 | Speak Az→De translation | P1 | In Az→De, tap the speaker next to a German translation | That translation is spoken in German. **VERIFY** — the FAQ says pronunciation works for De→Az only | M | |
| WORD-15 | Speech stops on close | P1 | Start speech, dismiss the sheet | Speech stops | M | |
| WORD-16 | Speech muted device | P2 | Mute device volume, tap speaker | No crash; no error dialog | M | |
| WORD-17 | Add bookmark | P0 | Tap the bookmark icon | Icon becomes active; success snackbar with the bare word (no article) and "Seçilmişlərə əlavə edildi" | W | |
| WORD-18 | Remove bookmark | P0 | Tap the active bookmark icon | Icon inactive; info snackbar "Seçilmişlərdən silindi" | W | |
| WORD-19 | Bookmark state on reopen | P0 | Bookmark, close sheet, open the same word again | Icon is active | W | |
| WORD-20 | Mark unknown | P1 | Tap the "?" icon | Active; snackbar "Bilinməyənlərə əlavə edildi" | W | |
| WORD-21 | Unmark unknown | P1 | Tap the active "?" icon | Inactive; snackbar "Bilinməyənlərdən silindi" | W | |
| WORD-22 | Bookmark and unknown are independent | P1 | Bookmark a word, then mark it unknown | Both flags stay set; removing one keeps the other | U | |
| WORD-23 | Bookmarks list updates behind the sheet | P1 | Toggle a bookmark from a Search sheet, close it, go to Bookmarks | List reflects the change | E | |
| WORD-24 | Bookmark failure | P2 | Force a DB failure (e.g. dev build with a broken DB) | Error snackbar "Nəsə səhv getdi"; icon not changed | U | |
| WORD-25 | Long content scrolls | P1 | Open a word with a long translation and examples | Sheet content scrolls; no overflow | W | |
| WORD-26 | Dismiss gestures | P2 | Swipe down and tap the scrim | Sheet closes | W | |
| WORD-27 | Large text | P2 | Largest system font size | Sheet is readable and scrollable; no overflow errors | M | |

---

## 5. Training (TRN)

Decks: levels A1, A2, B1, B2, C1, C2 and 11 topics (food & drink, family,
animals, plants & nature, body & health, clothes, house & home, travel,
time & weather, numbers, shopping).

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| TRN-01 | Deck overview | P0 | Fresh install, open Training | Level cards A1–C2 and "Gündəlik mövzular" topic cards are shown with counts (0 / total) | W | |
| TRN-02 | Totals per deck | P1 | Compare totals with the dictionary data | Each card shows the correct word total; topic totals match `assets/training_topics.json` | U | |
| TRN-03 | Open a level | P0 | Tap A1 | Loader, then first word card; counter `1 / total`; back bar shows "A1" | W | |
| TRN-04 | Open a topic | P0 | Tap a topic | Words load; back bar shows the translated topic name | W | |
| TRN-05 | Word card content | P0 | Look at a card | German word with article colour, translation, grammar info, speaker, bookmark and "?" actions | W | |
| TRN-06 | Next button | P0 | Tap "İrəli" | Next card with fade/slide animation; counter +1 | W | |
| TRN-07 | Previous button | P0 | Tap "Geri" | Previous card; counter −1 | W | |
| TRN-08 | Swipe left / right | P0 | Swipe left, then right | Left = next, right = previous | W | |
| TRN-09 | First card boundary | P1 | On card 1 tap Geri or swipe right | Nothing happens; Geri is disabled | U | |
| TRN-10 | Last card boundary | P1 | Jump to the last card, tap İrəli or swipe left | Nothing happens; İrəli is disabled; no crash | U | |
| TRN-11 | Short or slow swipe | P2 | Swipe slowly / very short | No page change (velocity < 400) | W | |
| TRN-12 | Order is stable | P0 | Open A1, note the first 5 words, back to levels, open A1 again | Same 5 words in the same order | U | |
| TRN-13 | Order is the same after restart | P0 | Note the first 5 words, kill and reopen the app | Same order (progress is stored as an index) | E | |
| TRN-14 | Topic order | P1 | Open a topic and page through | Easier levels (A1…) come first, mixed within each level | U | |
| TRN-15 | Progress saved on next | P0 | Go to card 10, back to levels | Level card shows progress `10 / total` | E | |
| TRN-16 | Resume position | P0 | Re-open the same level | Opens on the saved card | E | |
| TRN-17 | Resume after kill | P0 | Go to card 15, kill app, reopen, open Training | Last deck re-opens directly on card 15 | E | |
| TRN-18 | Progress per deck | P1 | Progress in A1 and B1 independently | Each deck keeps its own position | U | |
| TRN-19 | Jump to word | P1 | Open the jump control, enter 50, confirm | Goes to word 50; button reads "50 nömrəli sözə keç" | W | |
| TRN-20 | Jump with slider | P1 | Drag the slider; use start/end shortcuts | Selected number and text field stay in sync; Başlanğıc = 1, Son = total | W | |
| TRN-21 | Jump out of range | P1 | Type 0, a number above the total, and non-numeric text | Value is clamped to 1…total; letters are ignored; no crash | U | |
| TRN-22 | Jump to current word | P2 | Jump to the card you are already on | Sheet closes; no state change or extra save | U | |
| TRN-23 | Bookmark from card | P0 | Tap the bookmark icon | Snackbar `"word" seçilmişlərə əlavə edildi`; appears in Bookmarks | W | |
| TRN-24 | Unbookmark from card | P1 | Tap again | Snackbar `… seçilmişlərdən silindi`; removed from Bookmarks | W | |
| TRN-25 | Bookmark state per card | P1 | Bookmark card 3, go next and back | Card 3 still shows the active icon; card 4 does not | W | |
| TRN-26 | Mark unknown from card | P0 | Tap the "?" icon | Snackbar `… bilinməyənlərə əlavə edildi`; appears under Bookmarks → Bilinməyənlər | W | |
| TRN-27 | Speak from card | P1 | Tap the speaker | German word spoken, animation on/off like in the word sheet | M | |
| TRN-28 | Back to levels | P0 | Tap back in the back bar | Level grid shows; progress is kept; banner disappears | W | |
| TRN-29 | Empty deck | P2 | (Dev only) deck with no words | Error text "Bu səviyyə üçün söz tapılmadı" with a back bar | U | |
| TRN-30 | Saved index beyond deck size | P2 | (Dev) saved index larger than the deck length | Opens on the last card, no crash | U | |
| TRN-31 | Banner only in a session | P1 | Ads granted: Training grid, then open a deck | No banner on the grid; banner on the card screen | M | |
| TRN-32 | Training offline | P0 | Airplane mode, run a full session | Works; progress is saved locally | E | |
| TRN-33 | Rapid next taps | P1 | Tap İrəli ten times quickly | Counter increases by exactly 10; no skipped or duplicated saves | W | |
| TRN-34 | Grid after sign-out | P0 | Signed in with progress, sign out, open Training | Grid shows 0 progress for all decks (no old values) | E | |
| TRN-35 | Grid after sign-in | P0 | Sign in to an account with cloud progress | Progress is restored on level cards | E | |
| TRN-36 | Large text | P2 | Largest font | Card content scrolls or wraps; nav buttons stay reachable | M | |

---

## 6. Translation quiz (QUIZ)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| QUIZ-01 | Quiz section cards | P0 | Open Quiz tab | Cards for Translation, Listening and Results with counts | W | |
| QUIZ-02 | Initial view | P0 | Open Translation | Start button "Testə başla" | W | |
| QUIZ-03 | Start | P0 | Tap start | Loader, then question 1 of 10 with 4 options and score 0 | W | |
| QUIZ-04 | Question header | P1 | During quiz | "Sual n / 10", "Xal: s", progress bar fills proportionally | W | |
| QUIZ-05 | Four distinct options | P0 | Look at several questions | Exactly 4 options per question, one correct, no duplicate texts | U | |
| QUIZ-06 | Select an option | P0 | Tap an option | Option is highlighted as selected; options are locked; Continue appears | W | |
| QUIZ-07 | Correct answer feedback | P0 | Select the correct option | Shown as correct (green) | W | |
| QUIZ-08 | Wrong answer feedback | P0 | Select a wrong option | Chosen option red, the correct one shown green | W | |
| QUIZ-09 | Continue | P0 | Tap Continue (Növbəti / Bitir on the last) | Next question; selected state reset; score +1 only for a correct answer | W | |
| QUIZ-10 | Last question label | P1 | Reach question 10 | Button reads "Bitir" | W | |
| QUIZ-11 | Complete | P0 | Finish all 10 | Result view: title and message by score band, score `x/10` | W | |
| QUIZ-12 | Score bands | P1 | Finish with 10, 9, 7, 5, 4, 0 correct (use QUIZ result view or a debug build) | ≥90%: "Təbriklər!"; ≥70%: "Əla nəticə!"; ≥50%: "Yaxşı cəhd!"; else "Davam edin!" with matching message | U | |
| QUIZ-13 | Answer breakdown | P1 | On the result view | Per-question list with the question, your answer and the correct answer | W | |
| QUIZ-14 | Result is saved | P0 | Finish a quiz, go to Results | New entry with date and score | E | |
| QUIZ-15 | Restart during quiz | P1 | Tap the refresh icon, confirm "Bəli" | New questions, score 0, question 1; no result saved for the abandoned run | W | |
| QUIZ-16 | Restart declined | P2 | Tap refresh, choose "Xeyr" | Dialog closes, quiz unchanged | W | |
| QUIZ-17 | Cancel quiz | P1 | Tap ×, confirm | Returns to the initial view; nothing saved | W | |
| QUIZ-18 | Cancel declined | P2 | Tap ×, choose "Xeyr" | Quiz continues unchanged | W | |
| QUIZ-19 | Play again from results | P1 | On result view tap restart/try again | New 10 questions | W | |
| QUIZ-20 | Questions differ between runs | P1 | Run the quiz twice | Different question sets/order (random) | U | |
| QUIZ-21 | De→Az direction | P0 | Direction De→Az, start | Questions are German words, options are Azerbaijani | W | |
| QUIZ-22 | Az→De direction | P0 | Switch to Az→De, start | Questions are Azerbaijani words, options are German | W | |
| QUIZ-23 | Switch direction mid-quiz | P1 | Start a quiz, switch the direction in the app bar | **VERIFY**: running quiz is unchanged and the new direction applies to the next start | W | |
| QUIZ-24 | Multi-translation word | P1 | Find a question whose word has several translations | Correct answer is the first translation without the "1." prefix | U | |
| QUIZ-25 | Error state | P1 | (Dev) force the data source to fail or return < 4 words | Error view with a "Yenidən cəhd et" button; retry works | U | |
| QUIZ-26 | Error text language | P2 | Cause QUIZ-25 with the app in German | **VERIFY**: the quiz error message is the hard-coded English "Failed to load quiz words", not localized | W | |
| QUIZ-27 | Leave and return | P1 | Mid-quiz, tap the back bar, reopen Translation | Quiz state is reset to the initial view. **VERIFY** this is intended | E | |
| QUIZ-28 | App backgrounded | P1 | Mid-quiz, background for 1 min, return | Quiz is unchanged | M | |
| QUIZ-29 | Double tap on Continue | P2 | Tap Continue rapidly twice | Only one question is advanced; no skipped question, no double score | W | |
| QUIZ-30 | Offline | P0 | Airplane mode, full quiz | Works; result saved locally | E | |
| QUIZ-31 | Banner in the section | P1 | Ads granted: Quiz cards, then open a section | No banner on the card list; banner inside a section | M | |
| QUIZ-32 | FAQ matches behaviour | P2 | Compare FAQ "Test necə işləyir?" with the quiz | "10 questions, 4 options, green/red feedback, total score at the end" is true | M | |

---

## 7. Listening quiz (LST)

Always uses the **De→Az** word list, whatever the direction switcher says.

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| LST-01 | Initial view | P0 | Quiz → Listening | Start button "Dinləmə testinə başla" | W | |
| LST-02 | Start | P0 | Tap start | First question appears and the word is spoken automatically | M | |
| LST-03 | Options | P0 | Look at a question | 4 German options, one is the spoken word | U | |
| LST-04 | Replay | P0 | Tap the speaker / "Yenidən dinləmək üçün toxun" | Word is spoken again; no stacking of speech | M | |
| LST-05 | Select answer | P0 | Tap an option | Locked, correct/incorrect feedback shown, Continue appears | W | |
| LST-06 | Continue | P0 | Tap Continue | Next question; the new word is spoken automatically; previous selection cleared | W | |
| LST-07 | Complete | P0 | Answer all questions | Result view with score and breakdown | W | |
| LST-08 | Result saved | P0 | Finish, open Results | New entry appears under the listening history ("Sessiya #n") | E | |
| LST-09 | Correct word recorded as listened | P2 | Answer a question correctly | Word is added to the listened-words table (check in DB) | U | |
| LST-10 | Restart / cancel | P1 | Use refresh and × with confirmation | Same behaviour as translation quiz (QUIZ-15 to QUIZ-18) | W | |
| LST-11 | Direction switcher has no effect | P2 | Open Listening, switch Az↔De | **VERIFY**: switcher is visible but listening stays German. Confirm if it should be hidden | W | |
| LST-12 | Not enough words | P2 | (Dev) DB with < 4 valid words | Error "Test üçün kifayət qədər söz yoxdur" | U | |
| LST-13 | TTS unavailable | P2 | Device without a German voice installed | No crash; user can still answer | M | |
| LST-14 | Speech while leaving | P1 | Back out of a question while speech plays | Speech stops | M | |
| LST-15 | Silent mode | P2 | Device on silent / media volume 0 | Questions are still answerable; no crash | M | |
| LST-16 | Headphones / Bluetooth | P2 | Use wired and Bluetooth headphones | Audio is routed correctly | M | |

---

## 8. Quiz results (RES)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| RES-01 | Empty state | P1 | New install, Quiz → Results | "Hələ test nəticələri yoxdur…" message | W | |
| RES-02 | Statistics | P0 | After 3 quizzes | "Ümumi Test" = 3 and "Orta Xal" = average percent | U | |
| RES-03 | History list | P0 | After 3 quizzes | Entries newest first: "Test #n", "Xal: x/10 (y%)", date | W | |
| RES-04 | Listening statistics | P1 | After 2 listening sessions | "Ümumi Sessiya" = 2; history shows "Sessiya #n" | U | |
| RES-05 | Translation vs listening sections | P1 | Have both kinds of results | Each is shown in its own section with its own stats | W | |
| RES-06 | Card counts on the Quiz tab | P1 | After results exist | Quiz, Listening and Results cards show matching counts (Results = Quiz + Listening) | W | |
| RES-07 | Counts refresh | P1 | Finish a quiz, tap back to the Quiz cards | Counts have increased | E | |
| RES-08 | Result detail | P2 | Open a past entry if tappable | Breakdown shows the stored answers | W | |
| RES-09 | Persistence | P1 | Kill and reopen the app | Results unchanged | E | |
| RES-10 | Signed-out cleanup | P0 | Signed in with results, sign out | Results are cleared from the device; counts show 0 | E | |
| RES-11 | Many results | P2 | 50+ results | List scrolls smoothly; stats stay correct | M | |

---

## 9. Bookmarks and unknown words (BKM)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| BKM-01 | Category cards | P0 | Open Bookmarks tab | Two cards: "Seçilmişlər" and "Bilinməyənlər", each with a count | W | |
| BKM-02 | Empty bookmarks | P0 | Open Seçilmişlər with none | "Seçilmiş sözlər yoxdur" + description | W | |
| BKM-03 | Empty unknown | P0 | Open Bilinməyənlər with none | "Bilinməyən söz yoxdur" + description | W | |
| BKM-04 | Bookmarks list | P0 | After bookmarking 3 words | All 3 shown with key and meaning | W | |
| BKM-05 | Open a bookmark | P0 | Tap an entry | Word sheet opens with correct content and an active bookmark icon | W | |
| BKM-06 | Remove with undo | P0 | Remove an entry | Entry disappears; snackbar with the bare word, "Seçilmişlərdən silindi" and "Geri al" | W | |
| BKM-07 | Undo works | P0 | Tap "Geri al" | Entry returns to the list | W | |
| BKM-08 | Undo timeout | P2 | Remove an entry and wait | Snackbar auto-dismisses; entry stays removed | W | |
| BKM-09 | Unknown list | P0 | Mark 2 words unknown | Both shown under Bilinməyənlər | W | |
| BKM-10 | Remove unknown with undo | P1 | Remove, then Geri al | Same as BKM-06 / BKM-07 for unknown words | W | |
| BKM-11 | Counts on cards | P1 | Add/remove entries, go back to the category cards | Counts update | W | |
| BKM-12 | Same word in both lists | P1 | Bookmark and mark unknown the same word | Appears in both lists; removing from one does not affect the other | U | |
| BKM-13 | Bookmarks from Az→De words | P1 | Bookmark a word found in Az→De | Appears in the list and opens correctly. **VERIFY** the bookmark is not mixed up with a De→Az word with the same key | U | |
| BKM-14 | Duplicate add | P1 | Bookmark the same word from Search and Training | Listed once | U | |
| BKM-15 | Persistence | P0 | Kill and reopen | Bookmarks and unknown words are still there | E | |
| BKM-16 | Back bar | P1 | Open a list, tap back | Returns to category cards; banner hidden again | W | |
| BKM-17 | Error state | P2 | (Dev) force a load failure | "Seçilmişləri yükləmək xətası" with message and "Yenidən cəhd et" button that reloads | W | |
| BKM-18 | Sign-out reset | P0 | Signed in with bookmarks, sign out | Bookmarks and unknown words are cleared | E | |
| BKM-19 | Large list | P2 | 200+ bookmarks | Lists load without a long freeze | M | |
| BKM-20 | Banner in a list | P1 | Ads granted | No banner on the category cards; banner inside a list | M | |
| BKM-21 | FAQ matches behaviour | P2 | Compare the FAQ entries on bookmarks and unknown words with the app | Descriptions match the UI (icons, where the lists are) | M | |

---

## 10. Authentication (AUTH)

Use test accounts only.

### 10.1 Sign in

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| AUTH-01 | Open sign-in | P0 | Settings → "Daxil ol" | Sign-in screen with email, password, Google, Apple (iOS) buttons | W | |
| AUTH-02 | Email sign-in success | P0 | Valid email + password | Loader, return to Settings, success snackbar "Uğurla daxil oldunuz", profile card shows name and email | E | |
| AUTH-03 | Required fields | P0 | Submit empty form | Errors "E-poçt ünvanı tələb olunur" and "Şifrə tələb olunur" | W | |
| AUTH-04 | Invalid email format | P0 | `abc`, `abc@`, `a b@c.com` | "Düzgün e-poçt ünvanı daxil edin" | W | |
| AUTH-05 | Short password | P1 | 5-character password | "Şifrə ən az 6 simvol olmalıdır" | W | |
| AUTH-06 | Wrong password | P0 | Valid email, wrong password | Error "E-poçt və ya şifrə yanlışdır." shown; user stays on the screen | E | |
| AUTH-07 | Unknown account | P1 | Unregistered email | Error shown (invalid-credential message) | E | |
| AUTH-08 | Disabled account | P2 | Disabled test user | "Bu hesab deaktiv edilib." | E | |
| AUTH-09 | Too many attempts | P2 | Repeated wrong passwords | "Çox sayda cəhd…" | M | |
| AUTH-10 | Offline | P1 | Airplane mode, sign in | "Şəbəkə xətası…" shown; no crash or endless loader | E | |
| AUTH-11 | Error can repeat | P1 | Trigger the same error twice | Message appears both times (state is reset between attempts) | U | |
| AUTH-12 | Password visibility | P2 | Tap the eye icon, if present | Password is toggled between hidden and visible | W | |
| AUTH-13 | Keyboard / autofill | P2 | Use password manager autofill, "next"/"done" keys | Fields fill and move correctly | M | |
| AUTH-14 | Error language | P1 | Trigger AUTH-06 with the app in German | **VERIFY**: Firebase error messages are hard-coded in Azerbaijani, not localized | W | |
| AUTH-15 | Double tap sign-in | P2 | Tap the button twice quickly | One request only | W | |

### 10.2 Password reset

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| AUTH-16 | Reset email sent | P0 | Enter a registered email, tap "Şifrəni unutdunuz?" | Success snackbar "Şifrə sıfırlama linki göndərildi"; email arrives | E | |
| AUTH-17 | Reset without email | P1 | Leave the email empty, tap the link | "Əvvəlcə e-poçt ünvanınızı daxil edin" | W | |
| AUTH-18 | Reset unknown email | P2 | Unregistered email | **VERIFY** app does not reveal whether the account exists (or shows an error consistently) | E | |
| AUTH-19 | Reset invalid email | P2 | `abc` | "E-poçt ünvanı düzgün formatda deyil." | E | |

### 10.3 Registration

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| AUTH-20 | Open register | P0 | Sign-in screen → "Qeydiyyat" | Register screen with name, email, password, confirm fields | W | |
| AUTH-21 | Register success | P0 | Valid data | Account created, signed in, display name = entered name | E | |
| AUTH-22 | Required fields | P0 | Submit empty | Name, email, password, confirm errors shown | W | |
| AUTH-23 | Name needs first and last name | P1 | Enter a single word as name | "Lütfən ad və soyadınızı daxil edin" | W | |
| AUTH-24 | Password mismatch | P0 | Different confirm value | "Şifrələr uyğun gəlmir" | W | |
| AUTH-25 | Weak password | P1 | 5 characters | "Şifrə ən az 6 simvol…" | W | |
| AUTH-26 | Email already used | P0 | Register an existing email | "Bu e-poçt ünvanı artıq istifadə olunur." | E | |
| AUTH-27 | Back to sign-in | P2 | Tap "Daxil olun" | Navigates to sign-in | W | |
| AUTH-28 | Names with special characters | P2 | Name `Əli Məmmədov`, `Jürgen Müller`, and a 100-char name | Name saved and shown correctly | E | |

### 10.4 Social sign-in

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| AUTH-30 | Google sign-in | P0 | Tap "Google ilə daxil ol", pick an account | Signed in, profile shows Google name and email | M | |
| AUTH-31 | Google cancelled | P0 | Close the Google chooser | Back to the sign-in screen with no error | M | |
| AUTH-32 | Apple sign-in (iOS) | P0 | Tap "Apple ilə daxil ol" | Signed in. Apple private relay email is handled (hidden or shown as relay) | M | |
| AUTH-33 | Apple cancelled | P0 | Dismiss the Apple sheet | No error message | M | |
| AUTH-34 | Apple button on Android | P1 | Open the sign-in screen on Android | **VERIFY**: Apple button is hidden or works as intended | M | |
| AUTH-35 | Same email, different provider | P2 | Register by email, then sign in with Google using the same email | Either linked or a clear error; no crash | M | |

### 10.5 Session

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| AUTH-40 | Session persists | P0 | Sign in, kill and reopen the app | Still signed in; profile card shows the account | E | |
| AUTH-41 | Session restore indicator | P1 | Reopen the app while signed in on a slow network | Account is shown immediately (not guest) while sync runs | E | |
| AUTH-42 | Guest persists | P1 | Use as guest, reopen | Still a guest; local data kept (not wiped on launch) | E | |
| AUTH-43 | Sign-in screen back button | P2 | Open sign-in, press back | Returns to Settings, still guest | W | |
| AUTH-44 | Settings profile card | P1 | Check guest and signed-in states | Guest: "Qonaq" + hint + Sign in button. Signed in: name, email, no Sign in button | W | |

---

## 11. Guest data and cloud sync (SYNC)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| SYNC-01 | Guest data dialog | P0 | As a guest add a bookmark and some progress, then sign in to a **new** account | Dialog "Məlumatlarınız saxlanılsın?" with Saxla / Sil | W | |
| SYNC-02 | Keep guest data | P0 | Choose "Saxla" | Local bookmarks, quiz results and progress are merged into the account and visible after sign-in; also present in the cloud (verify by signing in on another device) | E | |
| SYNC-03 | Discard guest data | P0 | Choose "Sil" | Local data is deleted; only the account's cloud data is present | E | |
| SYNC-04 | No dialog without guest data | P1 | Fresh guest (no data) signs in | No dialog; signs in directly | E | |
| SYNC-05 | No dialog for returning user | P1 | Sign out and sign in to the same account again | No dialog (local DB was cleared on sign-out) | E | |
| SYNC-06 | Dialog can't be skipped | P1 | When the dialog is shown tap outside / press back | **VERIFY**: user can't end up half signed-in | W | |
| SYNC-07 | Restore on a new device | P0 | Sign in to account A on a fresh install | Bookmarks, unknown words, quiz/listening results and training progress are restored | E | |
| SYNC-08 | Sync a new bookmark | P0 | Signed in, add a bookmark, check on a second device | Appears on the second device after re-login / refresh | E | |
| SYNC-09 | Sync a removal | P1 | Remove a bookmark on device 1 | Removed on device 2 after sync | E | |
| SYNC-10 | Sync a quiz result | P1 | Finish a quiz on device 1 | Result visible on device 2 | E | |
| SYNC-11 | Sync training progress | P0 | Reach card 20 of A1 on device 1, sign in on device 2 | Device 2 opens A1 on card 20 | E | |
| SYNC-12 | Progress conflict | P1 | Different positions on two devices, sign in on both | **VERIFY** the merge rule (most recent / furthest). Result must be consistent on both | U | |
| SYNC-13 | Signed in offline | P0 | Airplane mode, add bookmark / finish quiz | Works locally with no error; syncs when the network returns | E | |
| SYNC-14 | Sign-in sync failure | P1 | Fail the network during the post-sign-in sync | User is still signed in; local data usable; no crash | E | |
| SYNC-15 | Sign out clears local data | P0 | Sign out | Bookmarks, unknown words, quiz/listening results, training progress and recent searches on the device are cleared; dialog confirmed the data stays in the cloud | E | |
| SYNC-16 | Switch accounts | P0 | Account A → sign out → sign in B | B never sees A's data; A's data returns when A signs in again | E | |
| SYNC-17 | Direct account switch | P1 | Sign in B without signing out A (if possible via Google chooser) | A's data is not left in B's account | E | |
| SYNC-18 | Guest data never uploaded without consent | P0 | Choose "Sil" in SYNC-03 and check Firestore | No guest data in the new account | M | |
| SYNC-19 | Pending progress flushed on sign-out | P1 | Move through several cards, sign out immediately | Last position is in the cloud after signing in again | E | |
| SYNC-20 | Firestore rules | P0 | Try reading another user's data with a second test user (rules emulator) | Access denied (`firestore.rules`) | M | |

---

## 12. Settings (SET)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| SET-01 | Screen layout | P0 | Open Settings | Profile card; Language, Theme; FAQ, Feedback, Privacy policy, Impressum, About rows; Privacy options only when required | W | |
| SET-02 | Language sheet | P0 | Tap Language | Sheet with Azərbaycan dili and Deutsch; the current one is marked | W | |
| SET-03 | Switch to German | P0 | Choose Deutsch | All visible text switches immediately; snackbar confirms the change | W | |
| SET-04 | Switch back to Azerbaijani | P0 | Choose Azərbaycan dili | UI returns to Azerbaijani | W | |
| SET-05 | Language persists | P0 | Switch, kill and reopen | Chosen language is kept | E | |
| SET-06 | Language applies everywhere | P1 | Switch to German and visit each tab and dialog | No leftover Azerbaijani strings except the data itself and the known hard-coded ones (see [open questions](#open-questions-found-while-writing-this)) | M | |
| SET-07 | Same language chosen again | P2 | Pick the current language | No error; sheet closes | W | |
| SET-08 | Translation completeness | P1 | Run `flutter test test/translations_test.dart` | `az.json` and `de.json` have identical keys | U | |
| SET-09 | Theme sheet | P0 | Tap Görünüş | Sheet with Light, Dark, System | W | |
| SET-10 | Light theme | P0 | Choose Açıq | App turns light immediately | W | |
| SET-11 | Dark theme | P0 | Choose Tünd | App turns dark immediately; contrast is fine on all screens | W | |
| SET-12 | System theme | P0 | Choose Sistem, change device appearance | App follows the system setting live | M | |
| SET-13 | Theme persists | P0 | Choose Dark, kill and reopen | Dark is applied from the first frame (no light flash). **VERIFY** flash | E | |
| SET-14 | Theme row subtitle | P2 | Change the theme | Row shows the current theme name | W | |
| SET-15 | Theme snackbar | P2 | Change the theme | Snackbar "Görünüş dəyişdirildi / Seçilən görünüş: …" | W | |
| SET-16 | FAQ list | P1 | Open FAQ | List of questions; row subtitle on Settings shows the same count as the list | W | |
| SET-17 | FAQ expand | P1 | Tap questions | Answers expand/collapse; long answers readable | W | |
| SET-18 | FAQ accuracy | P2 | Read every answer in `az` and `de` | Answers match current behaviour (levels, topics, pronunciation, sign-in benefits…) | M | |
| SET-19 | About screen | P1 | Open About | Dictionary source credit (Ramil Səfiyev), levels explanation, version | W | |
| SET-20 | Version shown | P1 | Compare with `pubspec.yaml` / the store build | Settings row and About show the correct version | M | |
| SET-21 | Privacy policy link | P0 | Tap | System browser opens the privacy page in the app language (az/de/en) | M | |
| SET-22 | Impressum link | P0 | Tap | Browser opens the Impressum in the app language | M | |
| SET-23 | Link in unsupported language | P2 | N/A for now (only az/de) | Falls back to the English page | U | |
| SET-24 | Link cannot open | P2 | Device with no browser / URL launch blocked | Error snackbar "Səhifəni açmaq mümkün olmadı" | W | |
| SET-25 | Links offline | P2 | Airplane mode, tap Privacy | Browser shows its own offline error; app doesn't crash | M | |
| SET-26 | Privacy options row | P1 | Device in the EEA / debug EEA (see ADS-05) | "Reklam məxfiliyi seçimləri" row appears and opens Google's form; row hidden elsewhere | M | |
| SET-27 | Back navigation | P2 | Back from each sub-screen | Returns to Settings | W | |

### 12.1 Feedback

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| SET-30 | Open sheet | P1 | Tap "Rəy göndər" | Sheet with Name and Message fields and a Send button | W | |
| SET-31 | Name prefilled | P2 | Open as a signed-in user | Name is prefilled with the display name; empty for a guest | W | |
| SET-32 | Required validation | P0 | Send with empty or whitespace-only fields | "Bu sahə boş ola bilməz" under each; nothing is sent | U | |
| SET-33 | Send success | P0 | Fill both fields, send | Success feedback "Rəyiniz göndərildi / Təşəkkür edirik!", sheet closes; document is created in Firestore | E | |
| SET-34 | Length limits | P1 | Type > 60 chars in Name, > 1000 in Message | Input is limited to 60 and 1000 characters with a counter | W | |
| SET-35 | Trimming | P2 | Send with spaces around text | Stored values are trimmed | U | |
| SET-36 | Network failure | P1 | Airplane mode, send | Error "Göndərmək alınmadı. İnternet bağlantınızı yoxlayıb…" and the text is kept for a retry | U | |
| SET-37 | Other failure | P2 | Force a Firestore rule rejection | Generic error "Bir az sonra yenidən cəhd edin" | U | |
| SET-38 | Double submit | P1 | Tap Send repeatedly | One feedback document only | U | |
| SET-39 | Keyboard handling | P2 | Open on a small screen with the keyboard | Fields and Send stay reachable | M | |
| SET-40 | Special characters | P2 | Send `ə ü 😀 <b>x</b>` | Stored and shown without corruption | E | |

### 12.2 Logout and delete account

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| ACC-01 | Buttons only when signed in | P0 | Guest vs signed in | Logout and Delete account buttons are visible only when signed in | W | |
| ACC-02 | Logout dialog | P0 | Tap "Çıxış" | Dialog explains local data will be deleted but stays in the cloud | W | |
| ACC-03 | Logout cancel | P1 | Choose "Ləğv et" | Nothing changes | W | |
| ACC-04 | Logout confirm | P0 | Confirm | Guest profile card, snackbar "Uğurla çıxış etdiniz", local data cleared on every tab | E | |
| ACC-05 | Delete dialog (email) | P0 | Tap "Hesabı sil" as an email user | Dialog with warning text and a password field | W | |
| ACC-06 | Delete dialog (social) | P1 | Same as a Google/Apple user | No password field; re-auth hint "Təsdiq üçün yenidən daxil olmağınız istənəcək." | W | |
| ACC-07 | Delete wrong password | P0 | Enter a wrong password | "Şifrə yanlışdır"; account still exists, still signed in | E | |
| ACC-08 | Delete empty password | P1 | Leave the password empty | Cannot confirm, or a validation error is shown | W | |
| ACC-09 | Delete success | P0 | Enter the correct password, "Sil" | Snackbar "Hesabınız silindi"; signed out; local and cloud data gone; signing in with the old credentials fails | E | |
| ACC-10 | Delete cancel | P1 | Choose "Ləğv et" | Nothing deleted | W | |
| ACC-11 | Delete network error | P1 | Airplane mode during delete | "Şəbəkə xətası…"; state unchanged | E | |
| ACC-12 | Delete social cancelled | P1 | Cancel the Google/Apple re-auth | No error, nothing deleted | M | |
| ACC-13 | Delete does not show as logout | P1 | After ACC-09 | Snackbar says "account deleted", not "logged out" | W | |
| ACC-14 | Delete page on the website | P2 | Open `docs/delete-account` page | Page explains deletion and is reachable from the store listing | M | |
| ACC-15 | Re-register after delete | P1 | Register again with the same email | Works, starts with empty data | E | |

---

## 13. Ads and consent (ADS)

Test with test ad units / debug build only. Never click real ads.

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| ADS-01 | Consent runs once | P0 | First launch | Consent flow starts after Home is visible; does not repeat on every tab switch | U | |
| ADS-02 | Banner after consent | P0 | Grant consent | Banner appears per the rules below | M | |
| ADS-03 | No banner if denied | P0 | Deny consent / consent not obtained | No banner space left empty | M | |
| ADS-04 | Banner placement | P1 | Visit all tabs | Banner is shown on Search; on Training, Quiz and Bookmarks only inside a practice screen / section, not on their card lists | M | |
| ADS-05 | EEA consent form | P0 | Debug build with `--dart-define=ADS_DEBUG_EEA=true` | Google's consent form appears | M | |
| ADS-06 | Privacy options | P1 | In EEA after consent, Settings → Privacy options | Form opens; changing the choice updates ad behaviour | M | |
| ADS-07 | iOS tracking prompt | P0 | iOS, first launch | App Tracking Transparency prompt appears (after the consent step) | M | |
| ADS-08 | iOS tracking denied | P1 | Deny tracking | App works; ads still non-personalized or none | M | |
| ADS-09 | Offline ads | P1 | Offline launch | App works; no empty gap or crash from the failed ad load | M | |
| ADS-10 | Banner doesn't cover UI | P1 | Check each screen on a small phone | Banner does not cover buttons; scrollable content reaches above it | M | |
| ADS-11 | Banner hides on leave | P1 | Open a practice screen, go back | Banner is removed from list screens again | M | |
| ADS-12 | Consent failure | P2 | Block the UMP request | App stays usable; ads stay off | M | |
| ADS-13 | Ad unit IDs | P0 | Check a release build | Production IDs are used in prod; test IDs in dev (`ad_unit_ids.dart`) | M | |

---

## 14. Cross-cutting

### 14.1 Localization and appearance (X-L10N)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| X-01 | Default language | P1 | Fresh install on a device set to English / German / Azerbaijani | Azerbaijani and German devices start in their own language; any other device language falls back to Azerbaijani (`fallbackLocale`). **VERIFY** | M | |
| X-02 | No raw keys | P0 | Walk through all screens in both languages | No visible translation keys such as `settings.title` | M | |
| X-03 | Text fits | P1 | German (longest strings) on a small phone | No overflow or clipped buttons | M | |
| X-04 | Placeholders | P1 | Check strings with `{}` (counts, names, scores) | Values are inserted in the right place | W | |
| X-05 | Dark mode contrast | P1 | Dark theme on every screen | Text is readable (≥ 4.5:1), no light-only icons or backgrounds | M | |
| X-06 | Dialog and sheet theming | P2 | Open dialogs, bottom sheets and snackbars in both themes | Correct colours | M | |
| X-07 | Fonts | P2 | Fresh install, offline | Text uses a fallback font without crashing if Google Fonts cannot load. **VERIFY** fonts are bundled or cached | M | |

### 14.2 Offline and connectivity (X-NET)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| X-10 | Guest offline | P0 | Airplane mode, use Search, Training, Quiz, Bookmarks | Everything works | E | |
| X-11 | Signed-in offline | P0 | Same as above while signed in | Works; syncs afterwards | E | |
| X-12 | Network drops during sign-in | P1 | Toggle airplane mode mid-request | Error shown; no infinite loader | M | |
| X-13 | Poor network | P2 | Throttle to 2G | No ANR or crash, loaders resolve | M | |

### 14.3 Lifecycle, install and upgrade (X-LIFE)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| X-20 | First launch DB setup | P0 | Fresh install | Dictionary DB is copied from assets; first search works; launch time acceptable (< 5 s on a mid device) | E | |
| X-21 | Upgrade keeps data | P0 | Install the previous release, add bookmarks / results / progress, upgrade to the new build | All data kept; dictionary updates apply (level and text migrations) | M | |
| X-22 | Upgrade keeps login | P1 | Same, while signed in | Still signed in | M | |
| X-23 | Dictionary text updates | P1 | Upgrade where words changed | Bookmarked words show updated text | U | |
| X-24 | Background / foreground | P1 | Background for 10 min on each tab | State is kept or sensibly restored; no crash | M | |
| X-25 | Process death | P1 | Developer options "Don't keep activities", switch away and back | App recovers without a crash | M | |
| X-26 | Low storage | P2 | Fill the device storage | First-launch DB copy failure shows a clear failure rather than a blank screen. **VERIFY** | M | |
| X-27 | Reinstall | P2 | Uninstall, install again, sign in | Cloud data is restored | M | |
| X-28 | Dev vs prod flavours | P1 | Run both entrypoints | Both start; prod uses prod Firebase and ads IDs | M | |

### 14.4 Accessibility (X-A11Y)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| X-30 | Screen reader labels | P1 | TalkBack / VoiceOver across the main flows | Icon-only buttons (speaker, bookmark, ?, ×, gear, refresh, direction switcher) have meaningful labels | M | |
| X-31 | Reading order | P2 | Swipe through a word sheet | Logical order | M | |
| X-32 | Largest font | P1 | Set the largest system font | No overflow, all actions reachable | M | |
| X-33 | Touch targets | P2 | Check small icons (close, refresh, bookmark) | At least 44×44 pt effective target | M | |
| X-34 | Colour independence | P2 | Quiz feedback with a colour-blindness simulator | Correct/wrong are distinguishable without colour alone. **VERIFY** (icons/labels) | M | |
| X-35 | Reduced motion | P2 | Enable "Remove animations" | App remains usable | M | |

### 14.5 Performance and stability (X-PERF)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| X-40 | Cold start | P1 | Kill and launch 5 times | Home visible quickly, consistent | M | |
| X-41 | Memory | P2 | Use all tabs for 15 min, profile memory | No steady growth | M | |
| X-42 | Speech and sheets churn | P2 | Open and close the word sheet 50 times with speech | No leak, no crash | M | |
| X-43 | Static checks | P1 | `flutter analyze` and `flutter test` | Zero analyzer errors; all tests pass | U | |

---

## 15. Release and store checks (REL)

| ID | Title | Pri | Steps | Expected | Auto | Result |
|----|-------|-----|-------|----------|------|--------|
| REL-01 | Version and build number | P0 | Compare `pubspec.yaml`, the Android bundle and the iOS build | All match | M | |
| REL-02 | Release signing | P0 | Install the release bundle | Signed with the release key; installs without a warning | M | |
| REL-03 | Store listing script | P1 | `python3 scripts/check_store_listing.py` | Passes (character limits, required fields) | U | |
| REL-04 | Privacy policy accuracy | P0 | Compare the policy with real data use (Firebase Auth, Firestore, Ads, feedback) | Every data type and SDK in the app is covered | M | |
| REL-05 | Permissions | P1 | Review the Android manifest and iOS plist | Only permissions that are needed and declared | M | |
| REL-06 | Screenshots current | P2 | Compare `screenshots/` with the UI | Match the current design | M | |
| REL-07 | Data safety / privacy labels | P0 | Compare `store/privacy-forms.md` with the app | Consistent with ads, accounts and analytics | M | |

---

## Run log

| Date | Tester | Build / version | Platform + OS | Language / theme | Suite | Passed | Failed | Blocked | Notes |
|------|--------|-----------------|---------------|------------------|-------|--------|--------|---------|-------|
| | | | | | | | | | |

## Defect log

| Case ID | Summary | Severity | Build | Link / ticket | Status |
|---------|---------|----------|-------|---------------|--------|
| | | | | | |

## Open questions found while writing this

These came out of reading the code. Each is marked **VERIFY** above; decide
whether the behaviour is intended or a bug, then update the expected result.

1. **Voice search** (SRCH-32): the README says "You can also search by voice",
   but nothing in `lib/` implements it.
2. **Non-ASCII case-insensitive search** (SRCH-08, SRCH-09): `searchWords` uses
   SQLite `LOWER()`, which does not lower-case `Ä Ö Ü Ə İ`. Searching with an
   upper-case non-ASCII letter may miss words.
3. **LIKE wildcards** (SRCH-17): user input is placed straight into a `LIKE`
   pattern, so `%` and `_` act as wildcards.
4. **Hard-coded auth error texts** (AUTH-14): `AuthCubit._mapFirebaseError`
   returns Azerbaijani strings regardless of the app language.
5. **Hard-coded quiz error** (QUIZ-26): `QuizBloc` emits the English
   "Failed to load quiz words".
6. **Direction switcher on Listening** (LST-11): the switcher is shown on the
   Quiz tab, but listening always uses the German list.
7. **Pronunciation for Az→De** (WORD-14): the FAQ says pronunciation exists for
   De→Az only, while the word sheet can speak Az→De translations.
8. **Leaving a quiz** (QUIZ-27): leaving a quiz mid-way and coming back resets it.
9. **Training progress merge rule** (SYNC-12): the conflict rule across devices
   is not documented.
10. **Bookmarks across directions** (BKM-13): confirm a bookmark is keyed so a
    word in `AzDe` cannot collide with the same text in `DeAz`.

## Suggested automation order

Starting points for the next phase, grouped by the **Auto** column:

- **Unit (U)**: `SearchBloc`, `QuizRepositoryImpl` (option building, first
  translation), `QuizBloc` scoring, `ListeningCubit`, `BookmarksBloc`,
  `TrainingCubit` (already partly covered), `AuthCubit` (sign-in/out, guest
  decision), sync repositories, `DBHelper` recent searches and `searchWords`
  ordering with `sqflite_common_ffi`, result score bands.
- **Widget (W)**: search states (initial, loading, loaded, empty, error),
  quiz question card, result view, dialogs, FAQ, settings rows, validation
  messages on sign-in/register and feedback.
- **E2E (E)**: the whole [Smoke suite](#1-smoke-suite) first, then search →
  bookmark → Bookmarks, training resume after restart, quiz end-to-end with
  saved result, sign in → guest data dialog → sync, sign out clean-up.
- **Manual only (M)**: speech, ads/consent, store links, third-party sign-in
  UIs, accessibility, visual checks.
