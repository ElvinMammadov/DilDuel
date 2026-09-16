import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/core/utils/grammar_type_translator.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';

/// Renders article + mainType + subType as a row of pill badges for a
/// [Word] entry. Shown for any entry that has at least one of those
/// fields set (both DeAz and AzDe).
///
/// Set [showArticle] to `false` in contexts where the article is already
/// visible inside the word key text (e.g. search result cards).  The
/// article color is still applied to the mainType badge so gender
/// information is preserved without duplication.
class WordTypeBadges extends StatelessWidget {
  const WordTypeBadges({
    super.key,
    required this.word,
    this.showArticle = true,
  });

  final Word word;

  /// Whether to render a standalone article badge ([der] / [die] / [das]).
  /// Pass `false` when the article is already part of the displayed word key.
  final bool showArticle;

  /// Extracts the first clean entry from a potentially numbered, multi-line
  /// DB value (e.g. `"1. Verb\n2. Adjektiv"` → `"Verb"`).
  /// DeAz single-value strings pass through unchanged.
  static String _firstEntry(String s) {
    final String first = s
        .split('\n')
        .map((String l) => l.trim())
        .firstWhere((String l) => l.isNotEmpty, orElse: () => s.trim());
    final RegExpMatch? m = RegExp(r'^\d+\.\s*').firstMatch(first);
    return m != null ? first.substring(m.end).trim() : first.trim();
  }

  Color _articleTextColor(AppColors colors) =>
      switch (word.article?.toLowerCase()) {
        'der' => colors.primary,
        'die' => colors.error,
        'das' => colors.success,
        _ => colors.textSecondary,
      };

  Color _articleBgColor(AppColors colors) =>
      switch (word.article?.toLowerCase()) {
        'der' => colors.primaryTint,
        'die' => colors.errorTint,
        'das' => colors.successTint,
        _ => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isAz = context.locale.languageCode == 'az';
    final List<Widget> badges = <Widget>[];

    // ── Article badge (bottom-sheet / detail views only) ──────────────────
    if (showArticle && word.article != null) {
      final Color articleText = _articleTextColor(colors);
      final Color articleBg = _articleBgColor(colors);
      badges.add(WordTypeBadge(
        label: word.article!,
        bg: articleBg,
        textColor: articleText,
        borderColor: articleText.withAlpha(60),
      ));
    }

    // ── Main type badge ───────────────────────────────────────────────────
    if (word.mainType != null) {
      final String rawLabel = _firstEntry(word.mainType!);
      if (rawLabel.isNotEmpty) {
        final String label =
            isAz ? GrammarTypeTranslator.mainType(rawLabel) : rawLabel;

        // When the article badge is hidden, apply the article gender colour to
        // the mainType badge so gender information is not lost.
        final bool colorByArticle = !showArticle && word.article != null;
        final Color articleText = _articleTextColor(colors);
        final Color articleBg = _articleBgColor(colors);
        badges.add(WordTypeBadge(
          label: label,
          bg: colorByArticle ? articleBg : colors.chipBg,
          textColor: colorByArticle ? articleText : colors.textSecondary,
          borderColor: colorByArticle ? articleText.withAlpha(60) : null,
        ));
      }
    }

    // ── Sub-type badge ────────────────────────────────────────────────────
    if (word.subType != null) {
      final String rawLabel = _firstEntry(word.subType!);
      if (rawLabel.isNotEmpty) {
        final String label =
            isAz ? GrammarTypeTranslator.subType(rawLabel) : rawLabel;
        badges.add(WordTypeBadge(
          label: label,
          bg: Colors.transparent,
          textColor: colors.textSecondary,
          borderColor: colors.border,
        ));
      }
    }

    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 4, children: badges);
  }
}

/// A single pill-shaped badge used inside [WordTypeBadges].
class WordTypeBadge extends StatelessWidget {
  const WordTypeBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.textColor,
    this.borderColor,
  });

  final String label;
  final Color bg;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding10,
          vertical: Dimensions.padding4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              BorderRadius.circular(Dimensions.borderRadiusPill),
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: Text(label, style: AppTextStyles.labelMedium(textColor)),
      );
}

/// Shows up to [_max] translation strings as pill chips with an overflow
/// count chip (`+N`) when there are more entries.
///
/// Used for AzDe cards in both Search and Bookmarks to render German
/// translation previews consistently.
class TranslationChips extends StatelessWidget {
  const TranslationChips({super.key, required this.translations});

  final List<String> translations;

  static const int _max = 3;

  /// Parses a raw AzDe `value` string (e.g. `"1. gehen\n2. fahren"`)
  /// into individual clean translation strings (`["gehen", "fahren"]`).
  static List<String> parse(String raw) {
    final RegExp numPrefix = RegExp(r'^\d+\.\s*');
    return raw
        .split('\n')
        .map((String l) => l.trim())
        .where((String l) => l.isNotEmpty)
        .map((String l) {
          final RegExpMatch? m = numPrefix.firstMatch(l);
          return m != null ? l.substring(m.end).trim() : l;
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (translations.isEmpty) return const SizedBox.shrink();
    final AppColors colors = AppColors.of(context);
    final List<String> visible = translations.take(_max).toList();
    final int overflow = translations.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: <Widget>[
        ...visible.map(
          (String t) => WordTypeBadge(
            label: t,
            bg: colors.chipBg,
            textColor: colors.textPrimary,
          ),
        ),
        if (overflow > 0)
          WordTypeBadge(
            label: '+$overflow',
            bg: Colors.transparent,
            textColor: colors.textSecondary,
            borderColor: colors.border,
          ),
      ],
    );
  }
}
