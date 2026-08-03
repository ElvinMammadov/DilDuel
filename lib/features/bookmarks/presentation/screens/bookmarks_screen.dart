part of bookmarks;

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

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
                primary: primary,
                primaryTint: primaryTint,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    size: Dimensions.itemHeight64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: Dimensions.itemHeight16),
                  Text(
                    'bookmarks.error'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Dimensions.itemHeight8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Dimensions.itemHeight16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookmarksBloc>().loadBookmarks();
                    },
                    child: Text('bookmarks.try_again'.tr()),
                  ),
                ],
              ),
            );
          }

          return Center(child: Text('common.something_wrong'.tr()));
        },
      );
}

class _BookmarksEmptyState extends StatelessWidget {
  final Color primary;
  final Color primaryTint;
  final Color textPrimary;
  final Color textSecondary;

  const _BookmarksEmptyState({
    required this.primary,
    required this.primaryTint,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: Dimensions.itemHeight72,
                height: Dimensions.itemHeight72,
                decoration:
                    BoxDecoration(color: primaryTint, shape: BoxShape.circle),
                child: Icon(Icons.bookmark_outline,
                    size: Dimensions.itemHeight30, color: primary),
              ),
              const SizedBox(height: Dimensions.itemHeight14),
              Text('bookmarks.empty'.tr(),
                  style:
                      AppTextStyles.titleMedium(textPrimary)),
              const SizedBox(height: Dimensions.itemHeight6),
              Text(
                'bookmarks.empty_description'.tr(),
                style: AppTextStyles.bodyMedium(textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _BookmarkItem extends StatelessWidget {
  const _BookmarkItem({
    required this.word,
    required this.onRemoveWithUndo,
  });

  final Word word;
  final VoidCallback onRemoveWithUndo;

  /// Fetches the full [Word] (with grammar fields) from the dictionary table
  /// then opens the shared bottom sheet.  Falls back to the stored bookmark
  /// data if the lookup fails (e.g. the DB was replaced).
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
                      // ── Word title ───────────────────────────
                      Text(
                        word.key,
                        style: AppTextStyles.wordSource(textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.itemHeight6),
                      // ── AzDe: translation chips ──────────────
                      // ── DeAz: translation text ───────────────
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
