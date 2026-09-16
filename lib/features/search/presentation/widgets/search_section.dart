part of search;

class SearchSection extends StatelessWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, AppState appState) {
        final String dictionaryName =
            context.read<AppCubit>().getDictionaryName();
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.padding8,
            horizontal: Dimensions.padding16,
          ),
          child: _PillSearchBar(
            onChanged: (String text) {
              if (text.trim().isEmpty) {
                context.read<SearchBloc>().clear();
              } else {
                context.read<SearchBloc>().search(text, dictionaryName);
              }
            },
            onClear: () => context.read<SearchBloc>().clear(),
          ),
        );
      },
    );
}

class _PillSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _PillSearchBar({
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_PillSearchBar> createState() => _PillSearchBarState();
}

class _PillSearchBarState extends State<_PillSearchBar> {
  final SearchController _controller = SearchController();
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color chipBg = isDark ? AppTheme.borderDark : AppTheme.chipBgLight;

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.padding16,
        vertical: Dimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                const BoxShadow(
                  color: Color(0x0A140A3C),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, size: Dimensions.itemWidth18, color: textSecondary),
          const SizedBox(width: Dimensions.itemWidth8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (String text) {
                setState(() => _isTyping = text.isNotEmpty);
                widget.onChanged(text);
              },
              style: AppTextStyles.bodyLarge(
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'search.placeholder'.tr(),
                hintStyle: AppTextStyles.bodyLarge(textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_isTyping)
            GestureDetector(
              onTap: () {
                _controller.clear();
                setState(() => _isTyping = false);
                widget.onClear();
              },
              child: Container(
                width: Dimensions.itemWidth24,
                height: Dimensions.itemHeight24,
                decoration: BoxDecoration(color: chipBg, shape: BoxShape.circle),
                child: Icon(
                  Icons.close,
                  size: Dimensions.itemWidth12,
                  color: textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
