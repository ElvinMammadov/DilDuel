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
      'settings.faq.sign_in_benefits',
      'settings.faq.sign_in_benefits_answer',
    ),
  ];

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
            return _SettingsCard(
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
