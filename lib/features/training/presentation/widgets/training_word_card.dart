part of training;

/// Article colours follow the standard German grammar colour convention.
Color _articleColor(String? article, bool isDark) {
  switch (article?.toLowerCase()) {
    case 'der':
      return isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
    case 'die':
      return isDark ? AppTheme.errorColorDark : AppTheme.errorColor;
    case 'das':
      return isDark ? AppTheme.successColorDark : AppTheme.successColor;
    default:
      return isDark
          ? AppTheme.textSecondaryDark
          : AppTheme.textSecondaryLight;
  }
}

class _TrainingWordCard extends StatelessWidget {
  final TrainingReady state;

  const _TrainingWordCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border =
        isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surface,
          borderRadius:
              BorderRadius.circular(Dimensions.borderRadiusLarge),
          border: Border.all(color: border),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _CardContent(
            key: ValueKey<int>(state.currentIndex),
            word: state.currentWord,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            border: border,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CardContent extends StatefulWidget {
  final Word word;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const _CardContent({
    super.key,
    required this.word,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  State<_CardContent> createState() => _CardContentState();
}

class _CardContentState extends State<_CardContent> {
  bool _isBookmarked = false;
  bool _isUnknown = false;

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

  Future<void> _toggleBookmark(BuildContext context) async {
    if (_isBookmarked) {
      await DBHelper.removeBookmark(widget.word);
      if (mounted) {
        setState(() => _isBookmarked = false);
        SnackbarUtils.showInfo(
          context,
          message: 'training.bookmark_removed'.tr(args: [widget.word.key]),
        );
      }
    } else {
      await DBHelper.addBookmark(widget.word);
      if (mounted) {
        setState(() => _isBookmarked = true);
        SnackbarUtils.showSuccess(
          context,
          message: 'training.bookmarked'.tr(args: [widget.word.key]),
        );
      }
    }
  }

  Future<void> _toggleUnknown(BuildContext context) async {
    if (_isUnknown) {
      await DBHelper.removeUnknownWord(widget.word);
      if (mounted) {
        setState(() => _isUnknown = false);
        SnackbarUtils.showInfo(
          context,
          message: 'training.unknown_removed'.tr(args: [widget.word.key]),
        );
      }
    } else {
      await DBHelper.addUnknownWord(widget.word);
      if (mounted) {
        setState(() => _isUnknown = true);
        SnackbarUtils.showSuccess(
          context,
          message: 'training.marked_unknown'.tr(args: [widget.word.key]),
        );
      }
    }
  }

  bool _ok(String? v) => v != null && v.trim().isNotEmpty;

  List<(String, String?, String)> _grammarRows(BuildContext context) {
    final bool isAz = context.locale.languageCode == 'az';
    final List<(String, String?, String)> r = <(String, String?, String)>[];

    void add(String deLabel, String key, String? v) {
      if (!_ok(v)) return;
      final String? azHint = isAz ? key.tr() : null;
      r.add((deLabel, azHint, v!.trim()));
    }

    add(GrammarDeLabels.genitiv, 'word.genitiv', widget.word.genitive);
    add(GrammarDeLabels.plural, 'word.plural', widget.word.plural);
    add(GrammarDeLabels.imperfekt, 'word.imperfekt', widget.word.imperfekt);
    add(GrammarDeLabels.perfekt, 'word.perfekt', widget.word.perfekt);
    add(GrammarDeLabels.komparativ, 'word.komparativ', widget.word.comparative);
    add(GrammarDeLabels.superlativ, 'word.superlativ', widget.word.superlative);
    return r;
  }

  String _bareWord(String key, String? article) {
    if (article == null || article.isEmpty) return key;
    final String prefix = '$article ';
    return key.startsWith(prefix) ? key.substring(prefix.length) : key;
  }

  String _typeLabel(BuildContext context) {
    final bool isAz = context.locale.languageCode == 'az';
    final StringBuffer b = StringBuffer();

    if (_ok(widget.word.mainType)) {
      final String raw = widget.word.mainType!;
      b.write(raw);
      if (isAz) {
        final String az = GrammarTypeTranslator.mainType(raw);
        if (az != raw) b.write(' ($az)');
      }
    }
    if (_ok(widget.word.gender)) {
      b.write(' · ');
      final String raw = widget.word.gender!;
      b.write(raw);
      if (isAz) {
        final String az = GrammarTypeTranslator.gender(raw);
        if (az != raw) b.write(' ($az)');
      }
    }
    if (_ok(widget.word.subType)) {
      b.write(' · ');
      final String raw = widget.word.subType!;
      b.write(raw);
      if (isAz) {
        final String az = GrammarTypeTranslator.subType(raw);
        if (az != raw) b.write(' ($az)');
      }
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final Color textPrimary = widget.textPrimary;
    final Color textSecondary = widget.textSecondary;
    final Color border = widget.border;
    final Color cardBg =
        isDark ? AppTheme.headerBgDark : AppTheme.backgroundLight;
    final Color primary =
        isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color chipBg = isDark ? AppTheme.borderDark : AppTheme.chipBgLight;

    final List<(String, String?, String)> grammar = _grammarRows(context);
    final bool hasGrammar = grammar.isNotEmpty;
    final bool hasSentence = _ok(widget.word.sentence);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.padding20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header: word info + action buttons ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Article chip
                    if (_ok(widget.word.article)) ...<Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.padding10,
                          vertical: Dimensions.padding3,
                        ),
                        decoration: BoxDecoration(
                          color: _articleColor(widget.word.article, isDark)
                              .withAlpha(28),
                          borderRadius: BorderRadius.circular(
                            Dimensions.borderRadiusPill,
                          ),
                        ),
                        child: Text(
                          widget.word.article!,
                          style: AppTextStyles.labelMedium(
                            _articleColor(widget.word.article, isDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.itemHeight6),
                    ],
                    // German word
                    Text(
                      _bareWord(widget.word.key, widget.word.article),
                      style: AppTextStyles.wordSource(textPrimary, size: 26),
                    ),
                    // Grammar type
                    if (_ok(widget.word.mainType)) ...<Widget>[
                      const SizedBox(height: Dimensions.itemHeight4),
                      Text(
                        _typeLabel(context),
                        style: AppTextStyles.bodySmall(textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Action buttons (row) ─────────────────────────────────
              Row(
                children: <Widget>[
                  _ActionButton(
                    icon: _isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    activeColor: primary,
                    activeBg: primaryTint,
                    inactiveBg: chipBg,
                    inactiveColor: textSecondary,
                    isActive: _isBookmarked,
                    onTap: () => _toggleBookmark(context),
                  ),
                  const SizedBox(width: Dimensions.itemWidth8),
                  _ActionButton(
                    icon: _isUnknown
                        ? Icons.help
                        : Icons.help_outline,
                    activeColor: AppTheme.warningColor,
                    activeBg: AppTheme.warningTint,
                    inactiveBg: chipBg,
                    inactiveColor: textSecondary,
                    isActive: _isUnknown,
                    onTap: () => _toggleUnknown(context),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: Dimensions.itemHeight16),
          Divider(color: border, height: 1),
          const SizedBox(height: Dimensions.itemHeight12),

          // ── Scrollable details ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.word.value,
                    style: AppTextStyles.bodyXLarge(textPrimary),
                  ),
                  if (hasGrammar) ...<Widget>[
                    const SizedBox(height: Dimensions.itemHeight16),
                    _SectionHeader(
                      label: 'word.grammar'.tr(),
                      textSecondary: textSecondary,
                      border: border,
                    ),
                    const SizedBox(height: Dimensions.itemHeight8),
                    _GrammarTable(
                      rows: grammar,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      border: border,
                      cardBg: cardBg,
                    ),
                  ],
                  if (hasSentence) ...<Widget>[
                    const SizedBox(height: Dimensions.itemHeight16),
                    _SectionHeader(
                      label: 'word.example'.tr(),
                      textSecondary: textSecondary,
                      border: border,
                    ),
                    const SizedBox(height: Dimensions.itemHeight8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.padding12),
                      decoration: BoxDecoration(
                        color: primaryTint,
                        borderRadius:
                            BorderRadius.circular(Dimensions.borderRadius),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.format_quote_rounded,
                            size: 14,
                            color: primary,
                          ),
                          const SizedBox(width: Dimensions.itemWidth8),
                          Expanded(
                            child: Text(
                              widget.word.sentence!.trim(),
                              style: AppTextStyles.bodySmall(textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Dimensions.itemHeight8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color activeColor;
  final Color activeBg;
  final Color inactiveColor;
  final Color inactiveBg;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.activeColor,
    required this.activeBg,
    required this.inactiveColor,
    required this.inactiveBg,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: Dimensions.itemWidth36,
          height: Dimensions.itemHeight36,
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: Dimensions.itemWidth18,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textSecondary;
  final Color border;

  const _SectionHeader({
    required this.label,
    required this.textSecondary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Text(label, style: AppTextStyles.labelSmall(textSecondary)),
          const SizedBox(width: Dimensions.itemWidth8),
          Expanded(child: Divider(color: border, height: 1, thickness: 1)),
        ],
      );
}

class _GrammarTable extends StatelessWidget {
  /// Each row: (German label, optional AZ tooltip, value).
  final List<(String, String?, String)> rows;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color cardBg;

  const _GrammarTable({
    required this.rows,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;
    final Color infoColor =
        isDark ? AppTheme.mainColorDark : AppTheme.mainColor;

    return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows.indexed
              .map(((int, (String, String?, String)) e) => Column(
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
                              width: 88,
                              child: Text.rich(
                                TextSpan(
                                  text: e.$2.$1,
                                  style: AppTextStyles.labelMedium(
                                    textSecondary,
                                  ),
                                  children: e.$2.$2 != null
                                      ? <InlineSpan>[
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.top,
                                            child: Tooltip(
                                              message: e.$2.$2!,
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              showDuration: const Duration(
                                                seconds: 4,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                  left: 2,
                                                ),
                                                child: Icon(
                                                  Icons.info_outline_rounded,
                                                  size: 10,
                                                  color: infoColor,
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
                                e.$2.$3,
                                style: AppTextStyles.bodyMedium(textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (e.$1 < rows.length - 1)
                        Divider(height: 1, color: border),
                    ],
                  ))
              .toList(),
        ),
      );
  }
}
