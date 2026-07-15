part of search;

class WordRow extends StatelessWidget {
  final String text;
  final bool isGerman;
  final bool isKey;
  final VoidCallback? onSpeak;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const WordRow({
    super.key,
    required this.text,
    required this.isGerman,
    required this.isKey,
    this.onSpeak,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Expanded(
        child: Text(
          text,
          style: isKey
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          )
              : Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
      ),
      if (isGerman) ...<Widget>[
        IconButton(
          icon: Icon(
            Icons.volume_up,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onSpeak,
          constraints: const BoxConstraints(),
          padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.padding8),
        ),
      ],
      if (isKey) ...<Widget>[
        IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onBookmark,
          constraints: const BoxConstraints(),
          padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.padding8),
        ),
      ],
    ],
  );
}