part of search;

void showSearchBottomSheet(
  BuildContext context,
  Word searchWord,
  String locale,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) => _SearchBottomSheetScreen(
      searchWord: searchWord,
      locale: locale,
    ),
    useSafeArea: true,
    isScrollControlled: true,
  );
}
