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
            final Color surface =
                isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
            final Color border =
                isDark ? AppTheme.borderDark : AppTheme.borderLight;
            final Color error =
                isDark ? AppTheme.errorColorDark : AppTheme.errorColor;

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
                  surface: surface,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primary: primary,
                  error: error,
                  onTap: () => showWordBottomSheet(
                    context,
                    word,
                    word.dicType == 'DeAz' ? 'de-DE' : 'az-AZ',
                    onBookmarkToggled: () =>
                        context.read<BookmarksBloc>().loadBookmarks(),
                  ),
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
  final Word word;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color error;
  final VoidCallback onTap;
  final VoidCallback onRemoveWithUndo;

  const _BookmarkItem({
    required this.word,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.error,
    required this.onTap,
    required this.onRemoveWithUndo,
  });

  @override
  Widget build(BuildContext context) => Padding(
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
            onTap: onTap,
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
                        Text(word.key,
                            style: AppTextStyles.wordSource(textPrimary)),
                        const SizedBox(height: Dimensions.itemHeight3),
                        Text(
                          word.value,
                          style: AppTextStyles.bodyMedium(textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
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
