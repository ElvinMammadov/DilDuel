part of search;

class _SearchBottomSheetScreen extends StatefulWidget {
  final Word searchWord;
  final String locale;

  const _SearchBottomSheetScreen({
    required this.searchWord,
    this.locale = 'de-DE',
  });

  @override
  State<_SearchBottomSheetScreen> createState() =>
      _SearchBottomSheetScreenState();
}

class _SearchBottomSheetScreenState extends State<_SearchBottomSheetScreen> {
  late final FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage(widget.locale);
    _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak() async {
    await _flutterTts.speak(widget.searchWord.key);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.padding16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.searchWord.key,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _speak,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: implement bookmark action
                    },
                  ),
                ],
              ),
            ),
            Text(
              widget.searchWord.value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
}
