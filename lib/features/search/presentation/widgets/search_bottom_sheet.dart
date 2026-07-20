part of search;

void showSearchBottomSheet(
  BuildContext context,
  Word searchWord,
  String locale, {
  VoidCallback? onBookmarkToggled,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) => _SearchBottomSheetScreen(
      searchWord: searchWord,
      locale: locale,
      onBookmarkToggled: onBookmarkToggled,
    ),
    useSafeArea: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.5,
      minHeight: MediaQuery.of(context).size.height * 0.3,
    ),
  );
}
