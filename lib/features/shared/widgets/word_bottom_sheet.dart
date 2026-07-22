import 'package:flutter/material.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

class _WordBottomSheetState extends State<WordBottomSheet>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _flutterTts;
  late final AnimationController _speakController;
  bool _isBookmarked = false;
  bool _isSpeaking = false;

  bool get _isDeAz => widget.locale == 'de-DE';

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('de-DE');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _speakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    final bool v = await DBHelper.isBookmarked(widget.word);
    if (mounted) setState(() => _isBookmarked = v);
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _speakController.stop();
      _speakController.reset();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    if (mounted) {
      setState(() => _isSpeaking = true);
      _speakController.repeat(reverse: true);
    }
    await _flutterTts.speak(widget.word.key);
  }

  /// Speaks [text] without toggling the main speaking indicator.
  /// Used for individual AzDe translation entries.
  Future<void> _speakText(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _toggleBookmark() async {
    try {
      if (_isBookmarked) {
        await DBHelper.removeBookmark(widget.word);
      } else {
        await DBHelper.addBookmark(widget.word);
      }
      if (mounted) {
        setState(() => _isBookmarked = !_isBookmarked);
        widget.onBookmarkToggled?.call();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update bookmark')),
        );
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary =
        isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color border =
        isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color surface =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color cardBg =
        isDark ? AppTheme.headerBgDark : AppTheme.backgroundLight;

    final Word word = widget.word;
    final bool hasSentence = _ok(word.sentence);
    final bool hasExample = _ok(word.example);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.borderRadiusSheet),
        ),
      ),
      child: Column(
        children: <Widget>[
          // ── Drag handle ──────────────────────────────────────
          const SizedBox(height: Dimensions.padding12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.padding16),

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
                  // ── Word + action buttons ──────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          word.key,
                          style: AppTextStyles.wordSource(
                            textPrimary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.itemWidth12),
                      if (_isDeAz)
                        _SpeakButton(
                          controller: _speakController,
                          isSpeaking: _isSpeaking,
                          primary: primary,
                          primaryTint: primaryTint,
                          onTap: _speak,
                        ),
                      if (_isDeAz)
                        const SizedBox(width: Dimensions.itemWidth8),
                      _CircleButton(
                        icon: _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: _isBookmarked
                            ? AppTheme.accentColor
                            : primary,
                        background: _isBookmarked
                            ? AppTheme.warningTint
                            : primaryTint,
                        onTap: _toggleBookmark,
                      ),
                    ],
                  ),

                  // ── Type line: article  mainType  subType ──
                  if (_typeLabel(word) != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: Dimensions.padding4),
                      child: Text(
                        _typeLabel(word)!,
                        style: AppTextStyles.bodySmall(
                          _typeColor(word.article, primary, textSecondary),
                        ),
                      ),
                    ),

                  const SizedBox(height: Dimensions.padding20),

                  // ── Translation ────────────────────────────
                  _SheetSection(
                    label: _isDeAz ? 'TƏRCÜMƏ' : 'ÜBERSETZUNG',
                    textSecondary: textSecondary,
                    border: border,
                  ),
                  const SizedBox(height: Dimensions.padding10),
                  if (_isDeAz)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.padding14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius:
                            BorderRadius.circular(Dimensions.borderRadius),
                      ),
                      child: Text(
                        word.value,
                        style: AppTextStyles.bodyLarge(textPrimary),
                      ),
                    )
                  else
                    _AzDeTranslationCard(
                      rows: _parseAzDeRows(word),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      border: border,
                      cardBg: cardBg,
                      primary: primary,
                      primaryTint: primaryTint,
                      onSpeak: _speakText,
                    ),

                  // ── Grammar ────────────────────────────────
                  if (word.hasGrammarForms) ...<Widget>[
                    const SizedBox(height: Dimensions.padding20),
                    _SheetSection(
                      label: 'QRAMMATİKA',
                      textSecondary: textSecondary,
                      border: border,
                    ),
                    const SizedBox(height: Dimensions.padding10),
                    _GrammarCard(
                      word: word,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      border: border,
                      cardBg: cardBg,
                    ),
                  ],

                  // ── Examples ───────────────────────────────
                  if (hasExample || hasSentence) ...<Widget>[
                    const SizedBox(height: Dimensions.padding20),
                    _SheetSection(
                      label: 'NÜMUNƏ',
                      textSecondary: textSecondary,
                      border: border,
                    ),
                    const SizedBox(height: Dimensions.padding10),
                    _ExamplesCard(
                      example: hasExample ? word.example : null,
                      sentence: hasSentence ? word.sentence : null,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primary: primary,
                      primaryTint: primaryTint,
                      border: border,
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

  String? _typeLabel(Word w) {
    if (w.dicType != 'DeAz') return null;
    final List<String> parts = <String>[];
    if (w.article != null) parts.add(w.article!);
    if (w.mainType != null) parts.add(w.mainType!);
    if (w.subType != null) parts.add(w.subType!);
    return parts.isEmpty ? null : parts.join('  ');
  }

  Color _typeColor(String? article, Color primary, Color secondary) =>
      switch (article?.toLowerCase()) {
        'der' => AppTheme.mainColor,
        'die' => AppTheme.errorColor,
        'das' => AppTheme.successColor,
        _ => secondary,
      };

  static String _stripNum(String s) {
    final RegExpMatch? m = RegExp(r'^\d+\.\s*').firstMatch(s);
    return m != null ? s.substring(m.end).trim() : s.trim();
  }

  List<(String?, String?, String)> _parseAzDeRows(Word w) {
    List<String> split(String? raw) => raw == null
        ? <String>[]
        : raw
            .split('\n')
            .map((String l) => l.trim())
            .where((String l) => l.isNotEmpty)
            .toList();

    final List<String> translations = split(w.value);
    final List<String> types = split(w.mainType).map(_stripNum).toList();
    final List<String> subtypes =
        split(w.subType).map(_stripNum).toList();

    return List<(String?, String?, String)>.generate(
      translations.length,
      (int i) {
        final String translation = _stripNum(translations[i]);
        final String? type =
            i < types.length && types[i].isNotEmpty ? types[i] : null;
        final String? subtype = i < subtypes.length &&
                subtypes[i].isNotEmpty
            ? subtypes[i]
            : null;
        return (type, subtype, translation);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.label,
    required this.textSecondary,
    required this.border,
  });

  final String label;
  final Color textSecondary;
  final Color border;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Text(label, style: AppTextStyles.labelSmall(textSecondary)),
          const SizedBox(width: Dimensions.itemWidth8),
          Expanded(
            child: Divider(color: border, height: 1, thickness: 1),
          ),
        ],
      );
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
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: color),
        ),
      );
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({
    required this.controller,
    required this.isSpeaking,
    required this.primary,
    required this.primaryTint,
    required this.onTap,
  });

  final AnimationController controller;
  final bool isSpeaking;
  final Color primary;
  final Color primaryTint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext ctx, Widget? _) {
            final double scale =
                isSpeaking ? 1.0 + controller.value * 0.1 : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSpeaking ? primary : primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSpeaking
                      ? Icons.stop_rounded
                      : Icons.volume_up_outlined,
                  size: 20,
                  color: isSpeaking ? Colors.white : primary,
                ),
              ),
            );
          },
        ),
      );
}

class _AzDeTranslationCard extends StatelessWidget {
  const _AzDeTranslationCard({
    required this.rows,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.cardBg,
    required this.primary,
    required this.primaryTint,
    required this.onSpeak,
  });

  final List<(String?, String?, String)> rows;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color cardBg;
  final Color primary;
  final Color primaryTint;
  final ValueChanged<String> onSpeak;

  String _typePrefix(String? main, String? sub) {
    final List<String> parts = <String>[];
    if (main != null && main.isNotEmpty) parts.add(main);
    if (sub != null && sub.isNotEmpty) parts.add(sub);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.indexed
            .map(((int, (String?, String?, String)) e) {
              final int i = e.$1;
              final (String? mainType, String? subType, String translation) =
                  e.$2;
              final String prefix = _typePrefix(mainType, subType);
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
                        // Index number
                        SizedBox(
                          width: 20,
                          child: Text(
                            '${i + 1}.',
                            style:
                                AppTextStyles.labelSmall(textSecondary),
                          ),
                        ),
                        // Type + translation
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (prefix.isNotEmpty)
                                Text(
                                  prefix,
                                  style: AppTextStyles.labelSmall(
                                    textSecondary,
                                  ),
                                ),
                              Text(
                                translation,
                                style:
                                    AppTextStyles.bodyLarge(textPrimary),
                              ),
                            ],
                          ),
                        ),
                        // Speaker button for each German word
                        GestureDetector(
                          onTap: () => onSpeak(translation),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primaryTint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.volume_up_outlined,
                              size: 15,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < rows.length - 1) Divider(height: 1, color: border),
                ],
              );
            })
            .toList(),
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  const _GrammarCard({
    required this.word,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.cardBg,
  });

  final Word word;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color cardBg;

  List<(String, String)> get _rows {
    final List<(String, String)> r = <(String, String)>[];
    void add(String label, String? v) {
      if (v != null && v.trim().isNotEmpty) r.add((label, v.trim()));
    }

    add('Genitiv', word.genitive);
    add('Plural', word.plural);
    add('Imperfekt', word.imperfekt);
    add('Perfekt', word.perfekt);
    add('Komparativ', word.comparative);
    add('Superlativ', word.superlative);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> rows = _rows;
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.indexed
            .map(((int, (String, String)) e) => _GrammarRow(
                  label: e.$2.$1,
                  value: e.$2.$2,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  showDivider: e.$1 < rows.length - 1,
                  border: border,
                ))
            .toList(),
      ),
    );
  }
}

class _GrammarRow extends StatelessWidget {
  const _GrammarRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    required this.showDivider,
    required this.border,
  });

  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final bool showDivider;
  final Color border;

  @override
  Widget build(BuildContext context) => Column(
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
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium(textSecondary),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium(textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider) Divider(height: 1, color: border),
        ],
      );
}

class _ExamplesCard extends StatelessWidget {
  const _ExamplesCard({
    required this.example,
    required this.sentence,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.primaryTint,
    required this.border,
  });

  final String? example;
  final String? sentence;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color primaryTint;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final bool bothPresent = example != null && sentence != null;
    return Container(
      decoration: BoxDecoration(
        color: primaryTint,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (example != null)
            _ExampleEntry(
              icon: Icons.short_text_rounded,
              label: 'Qısa nümunə',
              text: example!.trim(),
              textPrimary: textPrimary,
              primary: primary,
              showDivider: bothPresent,
              border: border,
            ),
          if (sentence != null)
            _ExampleEntry(
              icon: Icons.format_quote_rounded,
              label: 'Cümlə nümunəsi',
              text: sentence!.trim(),
              textPrimary: textPrimary,
              primary: primary,
              showDivider: false,
              border: border,
            ),
        ],
      ),
    );
  }
}

class _ExampleEntry extends StatelessWidget {
  const _ExampleEntry({
    required this.icon,
    required this.label,
    required this.text,
    required this.textPrimary,
    required this.primary,
    required this.showDivider,
    required this.border,
  });

  final IconData icon;
  final String label;
  final String text;
  final Color textPrimary;
  final Color primary;
  final bool showDivider;
  final Color border;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(Dimensions.padding14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon, size: 13, color: primary),
                    const SizedBox(width: 4),
                    Text(label, style: AppTextStyles.labelSmall(primary)),
                  ],
                ),
                const SizedBox(height: Dimensions.itemHeight6),
                Text(text, style: AppTextStyles.bodySmall(textPrimary)),
              ],
            ),
          ),
          if (showDivider) Divider(height: 1, color: border),
        ],
      );
}

