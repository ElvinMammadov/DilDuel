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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                            color: primaryTint, shape: BoxShape.circle),
                        child: Icon(Icons.bookmark_outline,
                            size: 30, color: primary),
                      ),
                      const SizedBox(height: 14),
                      Text('bookmarks.empty'.tr(),
                          style: AppTheme.titleMedium(textPrimary)
                              .copyWith(fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(
                        'bookmarks.empty_description'.tr(),
                        style: AppTheme.bodyMedium(textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: state.bookmarks.length,
              itemBuilder: (BuildContext context, int index) {
                final Word word = state.bookmarks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: Key(word.key),
                    background: Container(
                      decoration: BoxDecoration(
                        color: error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete_outline, color: error),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      context.read<BookmarksBloc>().removeBookmark(word);
                      SnackbarUtils.showInfo(
                        context,
                        message: 'bookmarks.removed'.tr(),
                        actionLabel: 'bookmarks.undo'.tr(),
                        onActionPressed: () =>
                            context.read<BookmarksBloc>().addBookmark(word),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: surface,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(word.key,
                                    style: AppTheme.wordSource(textPrimary)),
                                const SizedBox(height: 3),
                                Text(word.value,
                                    style: AppTheme.bodyMedium(textSecondary)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<BookmarksBloc>()
                                  .removeBookmark(word);
                              SnackbarUtils.showInfo(
                                context,
                                message: 'bookmarks.removed'.tr(),
                                actionLabel: 'bookmarks.undo'.tr(),
                                onActionPressed: () => context
                                    .read<BookmarksBloc>()
                                    .addBookmark(word),
                              );
                            },
                            child:
                                Icon(Icons.bookmark, size: 20, color: primary),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    size: 64,
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
