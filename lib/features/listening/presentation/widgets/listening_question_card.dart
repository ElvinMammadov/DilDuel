part of listening;

class ListeningQuestionCard extends StatefulWidget {
  final ListeningQuestion question;
  final void Function(String) onAnswer;

  const ListeningQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<ListeningQuestionCard> createState() => _ListeningQuestionCardState();
}

class _ListeningQuestionCardState extends State<ListeningQuestionCard> {
  final SpeechCubit _speech = SpeechCubit();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
  }

  @override
  void didUpdateWidget(ListeningQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) _speakQuestion();
  }

  @override
  void dispose() {
    _speech.close();
    super.dispose();
  }

  void _speakQuestion() => _speech.speak(widget.question.word.key);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: Dimensions.padding16),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding20,
            vertical: Dimensions.padding27,
          ),
          decoration: BoxDecoration(
            color: colors.primaryTint,
            border: Border.all(
              color: colors.primary,
              width: Dimensions.borderWidthEmphasis,
            ),
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          ),
          child: Column(
            children: <Widget>[
              AppSpeakButton(
                speech: _speech,
                text: widget.question.word.key,
                size: Dimensions.itemHeight72,
                iconSize: Dimensions.itemHeight36,
                icon: Icons.headphones_rounded,
                idleColor: colors.primary.withValues(alpha: 0.15),
                pulse: 0.15,
              ),
              const SizedBox(height: Dimensions.itemHeight12),
              Text(
                'listening.tap_to_replay'.tr(),
                style: AppTextStyles.bodySmall(colors.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.itemHeight20),
        AnswerOptions(
          options: widget.question.options,
          correctAnswer: widget.question.correctAnswer,
          onAnswer: widget.onAnswer,
        ),
      ],
    );
  }
}
