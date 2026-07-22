part of search;

// Delegates to the shared word_bottom_sheet so both Search and Bookmarks
// can open the same detail sheet without a circular import.
void showSearchBottomSheet(
  BuildContext context,
  Word searchWord,
  String locale, {
  VoidCallback? onBookmarkToggled,
}) =>
    showWordBottomSheet(
      context,
      searchWord,
      locale,
      onBookmarkToggled: onBookmarkToggled,
    );
