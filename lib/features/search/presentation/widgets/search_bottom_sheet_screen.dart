part of search;

class _SearchBottomSheetScreen extends StatefulWidget {
  final Word searchWord;
  final String locale;
  final VoidCallback? onBookmarkToggled;

  const _SearchBottomSheetScreen({
    required this.searchWord,
    this.locale = 'de-DE',
    this.onBookmarkToggled,
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
    final bool isBookmarked = await DBHelper.isBookmarked(widget.searchWord);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
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
        widget.onBookmarkToggled?.call();
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
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.borderRadiusSheet)),
      ),
      padding: const EdgeInsets.fromLTRB(
        Dimensions.padding24,
        Dimensions.padding10,
        Dimensions.padding24,
        Dimensions.padding44,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drag handle
          Center(
            child: Container(
              width: Dimensions.itemWidth36,
              height: Dimensions.itemHeight5,
              margin: const EdgeInsets.only(bottom: Dimensions.padding14),
              decoration: BoxDecoration(
                color: border,
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
            ),
          ),
          // Word + TTS + bookmark row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.searchWord.key,
                  style: AppTextStyles.wordSource(textPrimary, size: 28),
                ),
              ),
              const SizedBox(width: Dimensions.itemWidth12),
              // TTS button
              GestureDetector(
                onTap: !_isAzDe ? () => _speak(widget.searchWord.key) : null,
                child: Container(
                  width: Dimensions.itemWidth46,
                  height: Dimensions.itemHeight46,
                  decoration:
                      BoxDecoration(color: primaryTint, shape: BoxShape.circle),
                  child: Icon(Icons.volume_up_outlined,
                      size: Dimensions.itemWidth19, color: primary),
                ),
              ),
              const SizedBox(width: Dimensions.itemWidth8),
              // Bookmark button
              GestureDetector(
                onTap: _toggleBookmark,
                child: Container(
                  width: Dimensions.itemWidth46,
                  height: Dimensions.itemHeight46,
                  decoration:
                      BoxDecoration(color: primaryTint, shape: BoxShape.circle),
                  child: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    size: Dimensions.itemWidth19,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.itemHeight10),
          // Translation
          Text(widget.searchWord.value,
              style: AppTextStyles.bodyXLarge(textSecondary)),
        ],
      ),
    );
  }
}
