import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_card.dart';
import 'package:flutter_dic/core/components/app_close_button.dart';
import 'package:flutter_dic/core/components/app_divider.dart';
import 'package:flutter_dic/core/components/app_drag_handle.dart';
import 'package:flutter_dic/core/components/app_snackbar.dart';
import 'package:flutter_dic/core/components/app_speak_button.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_dic/core/state/speech_cubit.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/bare_word.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/core/utils/grammar_de_labels.dart';
import 'package:flutter_dic/core/utils/grammar_type_translator.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/shared/widgets/article_chip.dart';
import 'package:flutter_dic/features/shared/widgets/word_type_badges.dart';

/// Opens the word detail bottom sheet from anywhere in the app.
///
/// [locale] should be `'de-DE'` for De→Az words and `'az-AZ'` for Az→De.
void showWordBottomSheet(
  BuildContext context,
  Word word,
  String locale, {
  VoidCallback? onBookmarkToggled,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext ctx) => WordBottomSheet(
      word: word,
      locale: locale,
      onBookmarkToggled: onBookmarkToggled,
    ),
    useSafeArea: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      minHeight: MediaQuery.of(context).size.height * 0.3,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Public widget used by both Search and Bookmarks
// ─────────────────────────────────────────────────────────────────────────────

class WordBottomSheet extends StatefulWidget {
  const WordBottomSheet({
    super.key,
    required this.word,
    this.locale = 'de-DE',
    this.onBookmarkToggled,
  });

  final Word word;
  final String locale;
  final VoidCallback? onBookmarkToggled;

  @override
  State<WordBottomSheet> createState() => _WordBottomSheetState();
}

class _WordBottomSheetState extends State<WordBottomSheet> {
  final SpeechCubit _speech = SpeechCubit();
  bool _isBookmarked = false;
  bool _isUnknown = false;

  bool get _isDeAz => widget.locale == 'de-DE';

  @override
  void initState() {
    super.initState();
    _initActionStates();
  }

  Future<void> _initActionStates() async {
    final List<bool> results = await Future.wait(<Future<bool>>[
      DBHelper.isBookmarked(widget.word),
      DBHelper.isUnknownWord(widget.word),
    ]);
    if (mounted) {
      setState(() {
        _isBookmarked = results[0];
        _isUnknown = results[1];
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final bool adding = !_isBookmarked;
    try {
      final BookmarkRepository repo = sl<BookmarkRepository>();
      if (_isBookmarked) {
        await repo.removeBookmark(widget.word);
      } else {
        await repo.addBookmark(widget.word);
      }
      if (mounted) {
        setState(() => _isBookmarked = !_isBookmarked);
        widget.onBookmarkToggled?.call();
        final String label = bareWord(widget.word);
        AppSnackbar.show(
          context,
          type: adding ? SnackbarType.success : SnackbarType.info,
          title: label,
          subtitle: adding ? 'word.saved'.tr() : 'word.removed'.tr(),
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(
          context,
          type: SnackbarType.error,
          title: 'common.something_wrong'.tr(),
        );
      }
    }
  }

  Future<void> _toggleUnknown() async {
    final bool adding = !_isUnknown;
    try {
      final BookmarkRepository repo = sl<BookmarkRepository>();
      if (_isUnknown) {
        await repo.removeUnknownWord(widget.word);
      } else {
        await repo.addUnknownWord(widget.word);
      }
      if (mounted) {
        setState(() => _isUnknown = !_isUnknown);
        final String label = bareWord(widget.word);
        AppSnackbar.show(
          context,
          type: adding ? SnackbarType.success : SnackbarType.info,
          title: label,
          subtitle: adding
              ? 'word.marked_unknown'.tr()
              : 'word.unknown_removed'.tr(),
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(
          context,
          type: SnackbarType.error,
          title: 'common.something_wrong'.tr(),
        );
      }
    }
  }

  @override
  void dispose() {
    _speech.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg =
        isDark ? colors.headerBg : Theme.of(context).scaffoldBackgroundColor;

    final Word word = widget.word;
    final bool hasSentence = _ok(word.sentence);
    final bool hasExample = _ok(word.example);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.borderRadiusSheet),
        ),
      ),
      child: Column(
        children: <Widget>[
          // ── Drag handle + close button ───────────────────────
          SizedBox(
            height: Dimensions.itemHeight56,
            child: Stack(
              children: <Widget>[
                const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: Dimensions.padding12),
                    child: AppDragHandle(),
                  ),
                ),
                Positioned(
                  top: Dimensions.padding8,
                  right: Dimensions.padding16,
                  child: AppCloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ───────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.padding24,
                0,
                Dimensions.padding24,
                Dimensions.padding44,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ── Article chip + action buttons ──────────
                  Row(
                    children: <Widget>[
                      if (_isDeAz && _ok(word.article))
                        ArticleChip(article: word.article!),
                      const Spacer(),
                      if (_isDeAz)
                        AppSpeakButton(speech: _speech, text: word.key),
                      if (_isDeAz) const SizedBox(width: Dimensions.itemWidth8),
                      _CircleButton(
                        icon: _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: _isBookmarked ? colors.accent : colors.primary,
                        background: _isBookmarked
                            ? colors.warningTint
                            : colors.primaryTint,
                        onTap: _toggleBookmark,
                      ),
                      const SizedBox(width: Dimensions.itemWidth8),
                      _CircleButton(
                        icon: _isUnknown
                            ? Icons.help
                            : Icons.help_outline,
                        color: _isUnknown ? colors.warning : colors.primary,
                        background: _isUnknown
                            ? colors.warningTint
                            : colors.primaryTint,
                        onTap: _toggleUnknown,
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.itemHeight6),

                  // ── Word ───────────────────────────────────
                  _SheetWord(
                    text: _isDeAz ? bareWord(word) : word.key,
                    color: colors.textPrimary,
                  ),

                  // ── Grammar type line (DeAz only) ─────────
                  if (_isDeAz && _ok(word.mainType)) ...<Widget>[
                    const SizedBox(height: Dimensions.itemHeight4),
                    Text(
                      _typeLabel(context),
                      style: AppTextStyles.bodySmall(colors.textSecondary),
                    ),
                  ],

                  const SizedBox(height: Dimensions.padding20),

                  // ── Translation ────────────────────────────
                  _SheetSection(label: 'word.translation'.tr()),
                  const SizedBox(height: Dimensions.padding10),
                  if (_isDeAz)
                    AppCard(
                      color: cardBg,
                      padding: const EdgeInsets.all(Dimensions.padding14),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          word.value,
                          style: AppTextStyles.bodyLarge(colors.textPrimary),
                        ),
                      ),
                    )
                  else
                    _AzDeTranslationCard(
                      rows: _parseAzDeRows(word),
                      cardBg: cardBg,
                      onSpeak: _speech.speakQuietly,
                    ),

                  // ── Grammar ────────────────────────────────
                  if (word.hasGrammarForms) ...<Widget>[
                    const SizedBox(height: Dimensions.padding20),
                    _SheetSection(label: 'word.grammar'.tr()),
                    const SizedBox(height: Dimensions.padding10),
                    _GrammarCard(word: word, cardBg: cardBg),
                  ],

                  // ── Examples ───────────────────────────────
                  if (hasExample || hasSentence) ...<Widget>[
                    const SizedBox(height: Dimensions.padding20),
                    _SheetSection(label: 'word.example'.tr()),
                    const SizedBox(height: Dimensions.padding10),
                    _ExamplesCard(
                      example: hasExample ? word.example : null,
                      sentence: hasSentence ? word.sentence : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _ok(String? v) => v != null && v.trim().isNotEmpty;

  /// Builds the grammar-type text line shown below the word heading,
  /// mirroring the Training card's [_typeLabel] with AZ parentheticals.
  String _typeLabel(BuildContext context) {
    final Word word = widget.word;
    final bool isAz = context.locale.languageCode == 'az';
    final StringBuffer b = StringBuffer();

    if (_ok(word.mainType)) {
      final String raw = word.mainType!;
      b.write(raw);
      if (isAz) {
        final String az = GrammarTypeTranslator.mainType(raw);
        if (az != raw) b.write(' ($az)');
      }
    }
    if (_ok(word.gender)) {
      b.write(' · ');
      final String raw = word.gender!;
      b.write(GrammarTypeTranslator.germanGender(raw));
      if (isAz) {
        final String az = GrammarTypeTranslator.gender(raw);
        if (az != raw) b.write(' ($az)');
      }
    }
    if (_ok(word.subType)) {
      b.write(' · ');
      final String raw = word.subType!;
      b.write(raw);
      if (isAz) {
        final String az = GrammarTypeTranslator.subType(raw);
        if (az != raw) b.write(' ($az)');
      }
    }
    return b.toString();
  }

  static String _stripNum(String s) {
    final RegExpMatch? m = RegExp(r'^\d+\.\s*').firstMatch(s);
    return m != null ? s.substring(m.end).trim() : s.trim();
  }

  List<(String?, String?, String?, String)> _parseAzDeRows(Word w) {
    final bool isAz = context.locale.languageCode == 'az';

    List<String> split(String? raw) => raw == null
        ? <String>[]
        : raw
            .split('\n')
            .map((String l) => l.trim())
            .where((String l) => l.isNotEmpty)
            .toList();

    final List<String> translations = split(w.value);
    final List<String> types = split(w.mainType).map(_stripNum).toList();
    final List<String> subtypes = split(w.subType).map(_stripNum).toList();

    return List<(String?, String?, String?, String)>.generate(
      translations.length,
      (int i) {
        final String translation = _stripNum(translations[i]);
        final String? rawType =
            i < types.length && types[i].isNotEmpty ? types[i] : null;
        final String? rawSubtype =
            i < subtypes.length && subtypes[i].isNotEmpty ? subtypes[i] : null;
        final String? type = rawType == null
            ? null
            : isAz
                ? GrammarTypeTranslator.mainType(rawType)
                : rawType;
        final String? subtype = rawSubtype == null
            ? null
            : isAz
                ? GrammarTypeTranslator.subType(rawSubtype)
                : rawSubtype;
        return (type, subtype, w.translationPluralAt(i), translation);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Row(
      children: <Widget>[
        Text(label, style: AppTextStyles.labelSmall(colors.textSecondary)),
        const SizedBox(width: Dimensions.itemWidth8),
        const Expanded(
          child: AppDivider(thickness: Dimensions.itemHeight1),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.background,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: Dimensions.itemWidth44,
          height: Dimensions.itemHeight44,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: Dimensions.itemHeight20, color: color),
        ),
      );
}

class _AzDeTranslationCard extends StatelessWidget {
  const _AzDeTranslationCard({
    required this.rows,
    required this.cardBg,
    required this.onSpeak,
  });

  final List<(String?, String?, String?, String)> rows;
  final Color cardBg;
  final ValueChanged<String> onSpeak;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final AppColors colors = AppColors.of(context);
    return AppCard(
      color: cardBg,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              rows.indexed.map(((int, (String?, String?, String?, String)) e) {
            final int i = e.$1;
            final (
              String? mainType,
              String? subType,
              String? plural,
              String translation,
            ) = e.$2;
            final bool hasType = (mainType != null && mainType.isNotEmpty) ||
                (subType != null && subType.isNotEmpty);
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.padding14,
                    vertical: Dimensions.padding10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: Dimensions.itemWidth20,
                        child: Text(
                          '${i + 1}.',
                          style: AppTextStyles.labelSmall(
                            colors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (hasType)
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: <Widget>[
                                  if (mainType != null && mainType.isNotEmpty)
                                    WordTypeBadge(
                                      label: mainType,
                                      bg: colors.chipBg,
                                      textColor: colors.textSecondary,
                                    ),
                                  if (subType != null && subType.isNotEmpty)
                                    WordTypeBadge(
                                      label: subType,
                                      bg: Colors.transparent,
                                      textColor: colors.textSecondary,
                                      borderColor: colors.border,
                                    ),
                                ],
                              ),
                            if (hasType)
                              const SizedBox(
                                height: Dimensions.itemHeight4,
                              ),
                            Text(
                              translation,
                              style: AppTextStyles.bodyLarge(
                                colors.textPrimary,
                              ),
                            ),
                            if (plural != null) ...<Widget>[
                              const SizedBox(height: Dimensions.itemHeight2),
                              Text(
                                '${'word.plural'.tr()}: $plural',
                                style: AppTextStyles.bodySmall(
                                  colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.itemWidth8),
                      GestureDetector(
                        onTap: () => onSpeak(translation),
                        child: SizedBox(
                          width: Dimensions.itemWidth32,
                          height: Dimensions.itemHeight32,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primaryTint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.volume_up_outlined,
                              size: Dimensions.itemHeight15,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < rows.length - 1)
                  const AppDivider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  const _GrammarCard({required this.word, required this.cardBg});

  final Word word;
  final Color cardBg;

  /// Each row: (German label, optional AZ tooltip, value).
  List<(String, String?, String)> _buildRows(BuildContext context) {
    final bool isAz = context.locale.languageCode == 'az';
    final List<(String, String?, String)> r = <(String, String?, String)>[];
    void add(String deLabel, String key, String? v) {
      if (v != null && v.trim().isNotEmpty) {
        r.add((deLabel, isAz ? key.tr() : null, v.trim()));
      }
    }

    add(GrammarDeLabels.genitiv, 'word.genitiv', word.genitive);
    add(GrammarDeLabels.plural, 'word.plural', word.plural);
    add(GrammarDeLabels.imperfekt, 'word.imperfekt', word.imperfekt);
    add(GrammarDeLabels.perfekt, 'word.perfekt', word.perfekt);
    add(GrammarDeLabels.komparativ, 'word.komparativ', word.comparative);
    add(GrammarDeLabels.superlativ, 'word.superlativ', word.superlative);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final List<(String, String?, String)> rows = _buildRows(context);
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppCard(
      color: cardBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.indexed
            .map(
              ((int, (String, String?, String)) e) => _GrammarRow(
                label: e.$2.$1,
                azHint: e.$2.$2,
                value: e.$2.$3,
                showDivider: e.$1 < rows.length - 1,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GrammarRow extends StatelessWidget {
  const _GrammarRow({
    required this.label,
    this.azHint,
    required this.value,
    required this.showDivider,
  });

  final String label;
  final String? azHint;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding14,
            vertical: Dimensions.padding10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 96,
                child: Text.rich(
                  TextSpan(
                    text: label,
                    style: AppTextStyles.labelMedium(colors.textSecondary),
                    children: azHint != null
                        ? <InlineSpan>[
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Tooltip(
                                message: azHint!,
                                triggerMode: TooltipTriggerMode.tap,
                                showDuration: const Duration(seconds: 4),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: Dimensions.padding2,
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: Dimensions.itemHeight10,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium(colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const AppDivider(),
      ],
    );
  }
}

class _ExamplesCard extends StatelessWidget {
  const _ExamplesCard({required this.example, required this.sentence});

  final String? example;
  final String? sentence;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool bothPresent = example != null && sentence != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (example != null)
            _ExampleEntry(
              text: example!.trim(),
              showDivider: bothPresent,
            ),
          if (sentence != null)
            _ExampleEntry(text: sentence!.trim(), showDivider: false),
        ],
      ),
    );
  }
}

class _ExampleEntry extends StatelessWidget {
  const _ExampleEntry({required this.text, required this.showDivider});

  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(Dimensions.padding14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.format_quote_rounded,
                size: Dimensions.itemHeight14,
                color: colors.primary,
              ),
              const SizedBox(width: Dimensions.itemWidth8),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodySmall(colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const AppDivider(),
      ],
    );
  }
}

/// The word in the sheet header.
///
/// A single long word (a German compound) is scaled down to fit on one line
/// instead of breaking mid-word; a phrase wraps normally.
class _SheetWord extends StatelessWidget {
  const _SheetWord({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Text word = Text(
      text,
      maxLines: text.contains(' ') ? null : 1,
      style: AppTextStyles.wordSource(color, size: 28),
    );
    if (text.contains(' ')) return word;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: word,
    );
  }
}
