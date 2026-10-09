part of '../settings.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<(String, String)> _items = <(String, String)>[
    (
      'settings.faq.dictionary_usage',
      'settings.faq.dictionary_usage_answer',
    ),
    (
      'settings.faq.dictionary_direction',
      'settings.faq.dictionary_direction_answer',
    ),
    (
      'settings.faq.articles',
      'settings.faq.articles_answer',
    ),
    (
      'settings.faq.pronunciation',
      'settings.faq.pronunciation_answer',
    ),
    (
      'settings.faq.training_usage',
      'settings.faq.training_usage_answer',
    ),
    (
      'settings.faq.bookmarks_usage',
      'settings.faq.bookmarks_usage_answer',
    ),
    (
      'settings.faq.unknown_words',
      'settings.faq.unknown_words_answer',
    ),
    (
      'settings.faq.quiz_usage',
      'settings.faq.quiz_usage_answer',
    ),
    (
      'settings.faq.quiz_results',
      'settings.faq.quiz_results_answer',
    ),
    (
      'settings.faq.listening_usage',
      'settings.faq.listening_usage_answer',
    ),
    (
      'settings.faq.offline_usage',
      'settings.faq.offline_usage_answer',
    ),
    (
      'settings.faq.theme_language_usage',
      'settings.faq.theme_language_usage_answer',
    ),
    (
      'settings.faq.sign_in_benefits',
      'settings.faq.sign_in_benefits_answer',
    ),
  ];

  static int get itemCount => _items.length;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DilDuelAppBar(
          title: 'settings.faq.title'.tr(),
          showBackButton: true,
          showProfileButton: false,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.padding18,
            Dimensions.padding16,
            Dimensions.padding18,
            Dimensions.padding30,
          ),
          itemCount: _items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.padding8),
          itemBuilder: (BuildContext context, int index) {
            final (String q, String a) = _items[index];
            return AppCard(
              child: _FaqItem(
                question: q.tr(),
                answer: a.tr(),
                showDivider: false,
              ),
            );
          },
        ),
      );
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool showDivider;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.showDivider,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding16,
                vertical: Dimensions.padding14),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(widget.question,
                        style: AppTextStyles.bodyMedium(colors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600))),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _open ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: Dimensions.itemWidth18,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.padding16,
              0,
              Dimensions.padding16,
              Dimensions.padding14,
            ),
            child: Text(widget.answer,
                style: AppTextStyles.bodyMedium(colors.textPrimary)
                    .copyWith(height: 1.5, fontSize: 13)),
          ),
        if (widget.showDivider) Divider(height: 1, color: colors.border),
      ],
    );
  }
}
