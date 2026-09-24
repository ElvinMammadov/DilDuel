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

class _ListeningQuestionCardState extends State<ListeningQuestionCard>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _flutterTts;
  late final AnimationController _speakController;
  bool _isSpeaking = false;
  String? _selectedAnswer;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('de-DE');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
      _speakController.stop();
      _speakController.reset();
    });
    _speakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  @override
  void didUpdateWidget(ListeningQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      setState(() {
        _selectedAnswer = null;
        _showAnswer = false;
      });
      _speak();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speakController.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _speakController.stop();
      _speakController.reset();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    if (mounted) {
      setState(() => _isSpeaking = true);
      _speakController.repeat(reverse: true);
    }
    await _flutterTts.speak(widget.question.word.key);
  }

  void _handleAnswer(String answer) {
    if (_showAnswer) return;
    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
    });
  }

  void _handleContinue() {
    if (_selectedAnswer == null) return;
    widget.onAnswer(_selectedAnswer!);
  }

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
            border: Border.all(color: colors.primary, width: 1.5),
            borderRadius:
                BorderRadius.circular(Dimensions.borderRadiusMedium),
          ),
          child: Column(
            children: <Widget>[
              _AnimatedSpeakerButton(
                controller: _speakController,
                isSpeaking: _isSpeaking,
                primary: colors.primary,
                onPrimary: colors.onPrimary,
                onTap: _speak,
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
        ...widget.question.options.map((String option) {
          final bool isSelected = _selectedAnswer == option;
          final bool isCorrect = widget.question.correctAnswer == option;

          Color bg = colors.surface;
          Color textColor = colors.textPrimary;
          Color borderColor = colors.border;

          if (_showAnswer) {
            if (isCorrect) {
              bg = colors.successTint;
              textColor = colors.success;
              borderColor = colors.success;
            } else if (isSelected) {
              bg = colors.errorTint;
              textColor = colors.error;
              borderColor = colors.error;
            } else {
              textColor = colors.textSecondary;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.padding10),
            child: GestureDetector(
              onTap: _showAnswer ? null : () => _handleAnswer(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.padding10,
                  horizontal: Dimensions.padding16,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius:
                      BorderRadius.circular(Dimensions.borderRadius),
                ),
                child: Text(
                  option,
                  style: AppTextStyles.labelLarge(textColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
        if (_showAnswer) ...<Widget>[
          const SizedBox(height: Dimensions.itemHeight10),
          GestureDetector(
            onTap: _handleContinue,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.padding14,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
              child: Text(
                'quiz.next'.tr(),
                style: AppTextStyles.titleSmall(colors.onPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimatedSpeakerButton extends StatelessWidget {
  final AnimationController controller;
  final bool isSpeaking;
  final Color primary;
  final Color onPrimary;
  final VoidCallback onTap;

  const _AnimatedSpeakerButton({
    required this.controller,
    required this.isSpeaking,
    required this.primary,
    required this.onPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext ctx, Widget? _) {
            final double scale =
                isSpeaking ? 1.0 + controller.value * 0.15 : 1.0;
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 72,
                height: 72,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isSpeaking
                        ? primary
                        : primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSpeaking
                        ? Icons.stop_rounded
                        : Icons.headphones_rounded,
                    size: 36,
                    color: isSpeaking ? onPrimary : primary,
                  ),
                ),
              ),
            );
          },
        ),
      );
}
