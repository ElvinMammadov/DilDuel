part of bookmarks;

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  static const String _keyBookmarks = 'bookmarks';
  static const String _keyUnknown = 'unknown';

  String? _selected;

  String _labelFor(String key) =>
      key == _keyUnknown ? 'bookmarks.unknown'.tr() : 'app.bookmarks'.tr();

  IconData _iconFor(String key) =>
      key == _keyUnknown ? Icons.help_outline : Icons.bookmark_outline;

  @override
  Widget build(BuildContext context) {
    final String? selected = _selected;
    if (selected == null) {
      return _BookmarkCategoryCards(
        labelFor: _labelFor,
        iconFor: _iconFor,
        onSelected: (String key) => setState(() => _selected = key),
      );
    }
    return Column(
      children: <Widget>[
        AppBackBar(
          label: _labelFor(selected),
          onBack: () => setState(() => _selected = null),
        ),
        Expanded(
          child: selected == _keyUnknown
              ? const _UnknownTab()
              : const _BookmarksTab(),
        ),
      ],
    );
  }
}

// ── Category cards ──────────────────────────────────────────────────────────

class _BookmarkCategoryCards extends StatelessWidget {
  const _BookmarkCategoryCards({
    required this.labelFor,
    required this.iconFor,
    required this.onSelected,
  });

  final String Function(String key) labelFor;
  final IconData Function(String key) iconFor;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return BlocBuilder<BookmarksBloc, BookmarksState>(
      builder: (BuildContext context, BookmarksState state) {
        final BookmarksLoaded? loaded = state is BookmarksLoaded ? state : null;
        return AppFilledCardList(
          children: <Widget>[
            _card(
              _BookmarksScreenState._keyBookmarks,
              colors.bookmarksCard,
              loaded?.bookmarks.length,
            ),
            _card(
              _BookmarksScreenState._keyUnknown,
              colors.unknownCard,
              loaded?.unknownWords.length,
            ),
          ],
        );
      },
    );
  }

  Widget _card(String key, Color color, int? count) => AppIconFilledCard(
        color: color,
        icon: iconFor(key),
        label: labelFor(key),
        count: count,
        onTap: () => onSelected(key),
      );
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
                Dimensions.padding16,
                Dimensions.padding8,
                Dimensions.padding16,
                Dimensions.padding20,
              ),
              itemCount: state.bookmarks.length,
              itemBuilder: (BuildContext context, int index) {
                final Word word = state.bookmarks[index];
                return _BookmarkItem(
                  word: word,
                  onRemoveWithUndo: () {
                    final String? article = word.article;
                    final String bare =
                        article != null && word.key.startsWith('$article ')
                            ? word.key.substring(article.length + 1)
                            : word.key;
                    context.read<BookmarksBloc>().removeBookmark(word);
                    AppSnackbar.show(
                      context,
                      type: SnackbarType.info,
                      title: bare,
                      subtitle: 'bookmarks.removed'.tr(),
                      action: SnackbarAction(
                        label: 'bookmarks.undo'.tr(),
                        onPressed: () =>
                            context.read<BookmarksBloc>().addBookmark(word),
                      ),
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
                Dimensions.padding16,
                Dimensions.padding8,
                Dimensions.padding16,
                Dimensions.padding20,
              ),
              itemCount: state.unknownWords.length,
              itemBuilder: (BuildContext context, int index) {
                final Word word = state.unknownWords[index];
                return _BookmarkItem(
                  word: word,
                  onRemoveWithUndo: () {
                    final String? article = word.article;
                    final String bare =
                        article != null && word.key.startsWith('$article ')
                            ? word.key.substring(article.length + 1)
                            : word.key;
                    context.read<BookmarksBloc>().removeUnknownWord(word);
                    AppSnackbar.show(
                      context,
                      type: SnackbarType.info,
                      title: bare,
                      subtitle: 'bookmarks.unknown_removed'.tr(),
                      action: SnackbarAction(
                        label: 'bookmarks.undo'.tr(),
                        onPressed: () =>
                            context.read<BookmarksBloc>().addUnknownWord(word),
                      ),
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
            Text(state.message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: Dimensions.itemHeight16),
            ElevatedButton(
              onPressed: () => context.read<BookmarksBloc>().loadBookmarks(),
              child: Text('bookmarks.try_again'.tr()),
            ),
          ],
        ),
      );
}

// ── Bookmark item (shared by all tabs) ──────────────────────────────────────

class _BookmarkItem extends StatelessWidget {
  const _BookmarkItem({
    required this.word,
    required this.onRemoveWithUndo,
  });

  final Word word;
  final VoidCallback onRemoveWithUndo;

  Future<void> _openDetails(BuildContext context) async {
    final Word? fullWord = await DBHelper.getWordByKey(word.key, word.dicType);
    if (!context.mounted) return;
    showWordBottomSheet(
      context,
      fullWord ?? word,
      word.dicType == 'DeAz' ? 'de-DE' : 'az-AZ',
      onBookmarkToggled: () => context.read<BookmarksBloc>().loadBookmarks(),
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
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Dimensions.padding16),
          child: Icon(Icons.delete_outline, color: colors.error),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onRemoveWithUndo(),
        child: AppCard(
          onTap: () => _openDetails(context),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding16,
            vertical: Dimensions.padding14,
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
    );
  }
}
