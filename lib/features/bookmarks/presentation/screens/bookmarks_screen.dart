part of bookmarks;

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  static const String _keyBookmarks = 'bookmarks';
  static const String _keyUnknown = 'unknown';

  static const List<String> _categories = <String>[
    _keyBookmarks,
    _keyUnknown,
  ];

  String _selected = _keyBookmarks;

  String _labelFor(String key) =>
      key == _keyBookmarks ? 'app.bookmarks'.tr() : 'bookmarks.unknown'.tr();

  IconData _iconFor(String key) =>
      key == _keyBookmarks ? Icons.bookmark_outline : Icons.help_outline;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Category dropdown ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding16,
            vertical: Dimensions.padding8,
          ),
          child: AppDropdown<String>(
            onSelected: (String key) => setState(() => _selected = key),
            itemsBuilder: (BuildContext ctx) {
              final bool dark =
                  Theme.of(ctx).brightness == Brightness.dark;
              final Color tp =
                  dark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
              final Color bd =
                  dark ? AppTheme.borderDark : AppTheme.borderLight;

              return <PopupMenuEntry<String>>[
                for (int i = 0; i < _categories.length; i++)
                  ...<PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: _categories[i],
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.padding16,
                        vertical: Dimensions.padding8,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            _iconFor(_categories[i]),
                            size: Dimensions.itemWidth20,
                            color: tp,
                          ),
                          const SizedBox(width: Dimensions.itemWidth12),
                          Text(
                            _labelFor(_categories[i]),
                            style: AppTextStyles.bodyLarge(tp),
                          ),
                        ],
                      ),
                    ),
                    if (i < _categories.length - 1)
                      PopupMenuDivider(height: 1, color: bd),
                  ],
              ];
            },
            child: Row(
              children: <Widget>[
                Icon(
                  _iconFor(_selected),
                  size: Dimensions.itemWidth20,
                  color: textPrimary,
                ),
                const SizedBox(width: Dimensions.itemWidth8),
                Expanded(
                  child: Text(
                    _labelFor(_selected),
                    style: AppTextStyles.bodyLarge(textPrimary),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: textSecondary,
                ),
              ],
            ),
          ),
        ),

        // ── Content ─────────────────────────────────────────────────
        Expanded(
          child: _selected == _keyBookmarks
              ? const _BookmarksTab()
              : const _UnknownTab(),
        ),
      ],
    );
  }
}


// ── Bookmarks tab ───────────────────────────────────────────────────────────

class _BookmarksTab extends StatelessWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (BuildContext context, BookmarksState state) {
          if (state is BookmarksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookmarksLoaded) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            final Color primary =
                isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
            final Color primaryTint =
                isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
            final Color textPrimary =
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
            final Color textSecondary = isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight;

            if (state.bookmarks.isEmpty) {
              return _BookmarksEmptyState(
                icon: Icons.bookmark_outline,
                primary: primary,
                primaryTint: primaryTint,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                title: 'bookmarks.empty'.tr(),
                description: 'bookmarks.empty_description'.tr(),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.padding20,
                Dimensions.padding8,
                Dimensions.padding20,
                Dimensions.padding20,
              ),
              itemCount: state.bookmarks.length,
              itemBuilder: (BuildContext context, int index) {
                final Word word = state.bookmarks[index];
                return _BookmarkItem(
                  word: word,
                  onRemoveWithUndo: () {
                    context.read<BookmarksBloc>().removeBookmark(word);
                    SnackbarUtils.showInfo(
                      context,
                      message: 'bookmarks.removed'.tr(),
                      actionLabel: 'bookmarks.undo'.tr(),
                      onActionPressed: () =>
                          context.read<BookmarksBloc>().addBookmark(word),
                    );
                  },
                );
              },
            );
          }
          if (state is BookmarksError) {
            return _BookmarksErrorView(state: state);
          }
          return Center(child: Text('common.something_wrong'.tr()));
        },
      );
}

// ── Unknown tab ─────────────────────────────────────────────────────────────

class _UnknownTab extends StatelessWidget {
  const _UnknownTab();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (BuildContext context, BookmarksState state) {
          if (state is BookmarksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookmarksLoaded) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            final Color primary = AppTheme.warningColor;
            final Color primaryTint = AppTheme.warningTint;
            final Color textPrimary =
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
            final Color textSecondary = isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight;

            if (state.unknownWords.isEmpty) {
              return _BookmarksEmptyState(
                icon: Icons.help_outline,
                primary: primary,
                primaryTint: primaryTint,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                title: 'bookmarks.unknown_empty'.tr(),
                description: 'bookmarks.unknown_empty_description'.tr(),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.padding20,
                Dimensions.padding8,
                Dimensions.padding20,
                Dimensions.padding20,
              ),
              itemCount: state.unknownWords.length,
              itemBuilder: (BuildContext context, int index) {
                final Word word = state.unknownWords[index];
                return _BookmarkItem(
                  word: word,
                  onRemoveWithUndo: () {
                    context.read<BookmarksBloc>().removeUnknownWord(word);
                    SnackbarUtils.showInfo(
                      context,
                      message: 'bookmarks.unknown_removed'.tr(),
                      actionLabel: 'bookmarks.undo'.tr(),
                      onActionPressed: () =>
                          context.read<BookmarksBloc>().addUnknownWord(word),
                    );
                  },
                );
              },
            );
          }
          if (state is BookmarksError) {
            return _BookmarksErrorView(state: state);
          }
          return Center(child: Text('common.something_wrong'.tr()));
        },
      );
}

// ── Shared empty state ──────────────────────────────────────────────────────

class _BookmarksEmptyState extends StatelessWidget {
  final IconData icon;
  final Color primary;
  final Color primaryTint;
  final Color textPrimary;
  final Color textSecondary;
  final String title;
  final String description;

  const _BookmarksEmptyState({
    required this.icon,
    required this.primary,
    required this.primaryTint,
    required this.textPrimary,
    required this.textSecondary,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Dimensions.padding30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: Dimensions.itemHeight72,
                height: Dimensions.itemHeight72,
                decoration: BoxDecoration(
                    color: primaryTint, shape: BoxShape.circle),
                child:
                    Icon(icon, size: Dimensions.itemHeight30, color: primary),
              ),
              const SizedBox(height: Dimensions.itemHeight14),
              Text(title, style: AppTextStyles.titleMedium(textPrimary)),
              const SizedBox(height: Dimensions.itemHeight6),
              Text(
                description,
                style: AppTextStyles.bodyMedium(textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ── Shared error view ───────────────────────────────────────────────────────

class _BookmarksErrorView extends StatelessWidget {
  final BookmarksError state;

  const _BookmarksErrorView({required this.state});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline,
                size: Dimensions.itemHeight64, color: AppTheme.errorColor),
            const SizedBox(height: Dimensions.itemHeight16),
            Text('bookmarks.error'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Dimensions.itemHeight8),
            Text(state.message,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: Dimensions.itemHeight16),
            ElevatedButton(
              onPressed: () =>
                  context.read<BookmarksBloc>().loadBookmarks(),
              child: Text('bookmarks.try_again'.tr()),
            ),
          ],
        ),
      );
}

// ── Bookmark item (shared by both tabs) ─────────────────────────────────────

class _BookmarkItem extends StatelessWidget {
  const _BookmarkItem({
    required this.word,
    required this.onRemoveWithUndo,
  });

  final Word word;
  final VoidCallback onRemoveWithUndo;

  Future<void> _openDetails(BuildContext context) async {
    final Word? fullWord =
        await DBHelper.getWordByKey(word.key, word.dicType);
    if (!context.mounted) return;
    showWordBottomSheet(
      context,
      fullWord ?? word,
      word.dicType == 'DeAz' ? 'de-DE' : 'az-AZ',
      onBookmarkToggled: () =>
          context.read<BookmarksBloc>().loadBookmarks(),
    );
  }

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
    final Color error =
        isDark ? AppTheme.errorColorDark : AppTheme.errorColor;
    final bool isAzDe = word.dicType == 'AzDe';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.padding10),
      child: Dismissible(
        key: Key(word.key),
        background: Container(
          decoration: BoxDecoration(
            color: error.withValues(alpha: 0.12),
            borderRadius:
                BorderRadius.circular(Dimensions.borderRadiusLarge),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Dimensions.padding16),
          child: Icon(Icons.delete_outline, color: error),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onRemoveWithUndo(),
        child: GestureDetector(
          onTap: () => _openDetails(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding16,
              vertical: Dimensions.padding14,
            ),
            decoration: BoxDecoration(
              color: surface,
              border: Border.all(color: border),
              borderRadius:
                  BorderRadius.circular(Dimensions.borderRadiusLarge),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        word.key,
                        style: AppTextStyles.wordSource(textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.itemHeight6),
                      if (isAzDe)
                        TranslationChips(
                          translations:
                              TranslationChips.parse(word.value),
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          border: border,
                        )
                      else
                        Text(
                          word.value,
                          style: AppTextStyles.bodyMedium(textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.itemWidth8),
                Icon(
                  Icons.chevron_right,
                  size: Dimensions.itemWidth18,
                  color: textSecondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


