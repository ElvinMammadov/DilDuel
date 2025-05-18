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
          localeId: locale,
          listenOptions: SpeechListenOptions(
            cancelOnError: true,
            partialResults: true,
            listenMode: ListenMode.confirmation,
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
        child: Column(
          children: <Widget>[
            SearchBar(
              controller: _controller,
              elevation:
                  const WidgetStatePropertyAll<double?>(0.5),
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: Dimensions.padding8),
              ),
              shape: const WidgetStatePropertyAll<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSizes.mainBorderRadius),
                  ),
                ),
              ),
              leading: const Icon(Icons.search),
              trailing: isTyping
                  ? <Widget>[
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            query = '';
                          });
                        },
                      ),
                    ]
                  : <Widget>[
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : null,
                        ),
                        onPressed: () => _startListening(dictionaryName),
                      ),
                    ],
              onChanged: (String text) {
                setState(() {
                  query = text;
                });
                context.read<SearchBloc>().search(text, dictionaryName);
              },
            ),
          ],
        ),
      );
    });
  }
}
