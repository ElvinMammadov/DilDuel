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
            if (state.bookmarks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: Dimensions.itemHeight16),
                    Text(
                      'No bookmarks yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: Dimensions.itemHeight8),
                    Text(
                      'Your bookmarked words will appear here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(Dimensions.padding16),
              itemCount: state.bookmarks.length,
              itemBuilder: (BuildContext context, int index) {
                final Word word = state.bookmarks[index];
                return Dismissible(
                  key: Key(word.key),
                  background: Container(
                    color: AppTheme.errorColor,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: Dimensions.padding16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (DismissDirection direction) {
                    context.read<BookmarksBloc>().removeBookmark(word);
                    SnackbarUtils.showInfo(
                      context,
                      message: 'Bookmark removed',
                      actionLabel: 'Undo',
                      onActionPressed: () {
                        context.read<BookmarksBloc>().addBookmark(word);
                      },
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(
                        word.key,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      subtitle: Text(word.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark,
                            color: AppTheme.mainColor),
                        onPressed: () {
                          context.read<BookmarksBloc>().removeBookmark(word);
                          SnackbarUtils.showInfo(
                            context,
                            message: 'Bookmark removed',
                            actionLabel: 'Undo',
                            onActionPressed: () {
                              context.read<BookmarksBloc>().addBookmark(word);
                            },
                          );
                        },
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
                    'Error loading bookmarks',
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
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      );
} 