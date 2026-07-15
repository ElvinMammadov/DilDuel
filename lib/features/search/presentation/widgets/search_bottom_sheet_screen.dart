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
  bool _isBookmarked = false;

  bool get _isAzDe => widget.locale == 'az-AZ';

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('de-DE');
    _flutterTts.setSpeechRate(0.5);
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    if (context.mounted) {
      final bool isBookmarked = await DBHelper.isBookmarked(widget.searchWord);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _toggleBookmark() async {
    try {
      if (_isBookmarked) {
        await DBHelper.removeBookmark(widget.searchWord);
      } else {
        await DBHelper.addBookmark(widget.searchWord);
      }
      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update bookmark'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Dimensions.padding16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WordRow(
              text: widget.searchWord.key,
              isGerman: !_isAzDe,
              isKey: true,
              onSpeak: !_isAzDe ? () => _speak(widget.searchWord.key) : null,
              onBookmark: _toggleBookmark,
              isBookmarked: _isBookmarked,
            ),
            const SizedBox(height: Dimensions.itemHeight16),
            WordRow(
              text: widget.searchWord.value,
              isGerman: _isAzDe,
              isKey: false,
              onSpeak: _isAzDe ? () => _speak(widget.searchWord.value) : null,
            ),
          ],
        ),
      );
}
