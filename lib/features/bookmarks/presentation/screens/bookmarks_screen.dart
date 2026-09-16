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
    final AppColors colors = AppColors.of(context);

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
              final AppColors ctxColors = AppColors.of(ctx);

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
                            color: ctxColors.textPrimary,
                          ),
                          const SizedBox(width: Dimensions.itemWidth12),
                          Text(
                            _labelFor(_categories[i]),
                            style: AppTextStyles.bodyLarge(
                              ctxColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _categories.length - 1)
                      PopupMenuDivider(height: 1, color: ctxColors.border),
                  ],
              ];
            },
            child: Row(
              children: <Widget>[
                Icon(
                  _iconFor(_selected),
                  size: Dimensions.itemWidth20,
                  color: colors.textPrimary,
                ),
                const SizedBox(width: Dimensions.itemWidth8),
                Expanded(
                  child: Text(
                    _labelFor(_selected),
                    style: AppTextStyles.bodyLarge(colors.textPrimary),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.textSecondary,
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
            final AppColors colors = AppColors.of(context);

            if (state.bookmarks.isEmpty) {
              return EmptyStateView(
                icon: Icons.bookmark_outline,
                color: colors.primary,
                tintColor: colors.primaryTint,
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
            final AppColors colors = AppColors.of(context);

            if (state.unknownWords.isEmpty) {
              return EmptyStateView(
                icon: Icons.help_outline,
                color: colors.warning,
                tintColor: colors.warningTint,
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

// ── Shared error view ───────────────────────────────────────────────────────

class _BookmarksErrorView extends StatelessWidget {
  final BookmarksError state;

  const _BookmarksErrorView({required this.state});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline,
                size: Dimensions.itemHeight64,
                color: AppColors.of(context).error),
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
    final AppColors colors = AppColors.of(context);
    final bool isAzDe = word.dicType == 'AzDe';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.padding10),
      child: Dismissible(
        key: Key(word.key),
        background: Container(
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.12),
            borderRadius:
                BorderRadius.circular(Dimensions.borderRadiusLarge),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Dimensions.padding16),
          child: Icon(Icons.delete_outline, color: colors.error),
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
              color: colors.surface,
              border: Border.all(color: colors.border),
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
                        style: AppTextStyles.wordSource(colors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.itemHeight6),
                      if (isAzDe)
                        TranslationChips(
                          translations: TranslationChips.parse(word.value),
                        )
                      else
                        Text(
                          word.value,
                          style: AppTextStyles.bodyMedium(colors.textSecondary),
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
                  color: colors.textSecondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


