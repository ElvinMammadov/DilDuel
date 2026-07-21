part of search;

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final SearchController _controller = SearchController();
  String query = '';
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechInitialized = await _speech.initialize(
      onStatus: (String status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (SpeechRecognitionError errorNotification) {
        setState(() => _isListening = false);
      },
    );

    setState(() {});
  }

  Future<void> _startListening(String dictionaryName) async {
    if (!_speechInitialized) {
      return;
    }

    if (!_isListening) {
      // Set language based on dictionary type
      final String locale = dictionaryName == 'AzDe' ? 'az-AZ' : 'de-DE';

      setState(() => _isListening = true);
      try {
        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            setState(() {
              query = result.recognizedWords;
              _controller.text = query;
            });
            context.read<SearchBloc>().search(query, dictionaryName);
          },
          listenOptions: SpeechListenOptions(
            cancelOnError: true,
            partialResults: true,
            listenMode: ListenMode.confirmation,
            localeId: locale,
          ),
        );
      } catch (e) {
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTyping = query.isNotEmpty;

    return BlocBuilder<AppCubit, AppState>(builder: (
      BuildContext context,
      AppState appState,
    ) {
      final String dictionaryName =
          context.read<AppCubit>().getDictionaryName();
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.padding8,
          horizontal: Dimensions.padding16,
        ),
        child: _PillSearchBar(
          controller: _controller,
          isTyping: isTyping,
          isListening: _isListening,
          onChanged: (String text) {
            setState(() => query = text);
            context.read<SearchBloc>().search(text, dictionaryName);
          },
          onClear: () => setState(() {
            _controller.clear();
            query = '';
          }),
          onMic: () => _startListening(dictionaryName),
        ),
      );
    });
  }
}

class _PillSearchBar extends StatelessWidget {
  final SearchController controller;
  final bool isTyping;
  final bool isListening;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onMic;

  const _PillSearchBar({
    required this.controller,
    required this.isTyping,
    required this.isListening,
    required this.onChanged,
    required this.onClear,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color chipBg =
        isDark ? AppTheme.borderDark : AppTheme.chipBgLight;

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16, vertical: Dimensions.padding10),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
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
          Icon(Icons.search,
              size: Dimensions.itemWidth18, color: textSecondary),
          const SizedBox(width: Dimensions.itemWidth8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
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
          if (isTyping)
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: Dimensions.itemWidth26,
                height: Dimensions.itemHeight26,
                decoration:
                    BoxDecoration(color: chipBg, shape: BoxShape.circle),
                child: Icon(Icons.close,
                    size: Dimensions.itemWidth12, color: textSecondary),
              ),
            )
          else
            GestureDetector(
              onTap: onMic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: Dimensions.itemWidth32,
                height: Dimensions.itemHeight32,
                decoration: BoxDecoration(
                  color: isListening
                      ? (isDark
                          ? AppTheme.errorTintDark
                          : AppTheme.errorTint)
                      : chipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  size: Dimensions.itemWidth15,
                  color: isListening ? AppTheme.errorColor : textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
