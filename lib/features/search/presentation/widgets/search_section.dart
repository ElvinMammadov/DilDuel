part of search;

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SearchBloc>().clear(
              context.read<AppCubit>().getDictionaryName(),
            );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<SearchBloc, SearchState>(
        listener: (BuildContext context, SearchState state) {
          if (state is SearchFillField) {
            _controller.text = state.query;
            context.read<SearchBloc>().search(
                  state.query,
                  context.read<AppCubit>().getDictionaryName(),
                );
          }
        },
        child: BlocListener<AppCubit, AppState>(
          listenWhen: (AppState previous, AppState current) =>
              previous.dictionaryType != current.dictionaryType,
          listener: (BuildContext context, AppState state) {
            final String query = _controller.text;
            final String dicType =
                context.read<AppCubit>().getDictionaryName();
            if (query.trim().isNotEmpty) {
              context.read<SearchBloc>().search(query, dicType);
            } else {
              context.read<SearchBloc>().clear(dicType);
            }
          },
          child: BlocBuilder<AppCubit, AppState>(
          builder: (BuildContext context, AppState appState) {
            final String dictionaryName =
                context.read<AppCubit>().getDictionaryName();
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.padding8,
                horizontal: Dimensions.padding16,
              ),
              child: _PillSearchBar(
                controller: _controller,
                onChanged: (String text) {
                  if (text.trim().isEmpty) {
                    context.read<SearchBloc>().clear(dictionaryName);
                  } else {
                    context.read<SearchBloc>().search(text, dictionaryName);
                  }
                },
                onClear: () =>
                    context.read<SearchBloc>().clear(dictionaryName),
              ),
            );
          },
          ),
        ),
      );
}

class _PillSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _PillSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_PillSearchBar> createState() => _PillSearchBarState();
}

class _PillSearchBarState extends State<_PillSearchBar> {
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncIsTyping);
  }

  @override
  void didUpdateWidget(_PillSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncIsTyping);
      widget.controller.addListener(_syncIsTyping);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncIsTyping);
    super.dispose();
  }

  void _syncIsTyping() {
    final bool typing = widget.controller.text.isNotEmpty;
    if (typing != _isTyping) setState(() => _isTyping = typing);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 1.5),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding12,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search,
                size: Dimensions.itemWidth18, color: colors.textSecondary),
            const SizedBox(width: Dimensions.itemWidth8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: AppTextStyles.bodyLarge(colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'search.placeholder'.tr(),
                  hintStyle: AppTextStyles.bodyLarge(colors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_isTyping)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onClear();
                },
                child: SizedBox(
                  width: Dimensions.itemWidth24,
                  height: Dimensions.itemHeight24,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.chipBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: Dimensions.itemWidth12,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
