import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/buttons/app_elevated_button.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A multiple-choice answer list followed by a "Next" button.
///
/// Tapping an option locks the list and reveals which answer was correct.
/// The "Next" button then reports the chosen answer through [onAnswer] and
/// resets the list for the following question.
class AnswerOptions extends StatefulWidget {
  const AnswerOptions({
    super.key,
    required this.options,
    required this.correctAnswer,
    required this.onAnswer,
  });

  final List<String> options;
  final String correctAnswer;
  final ValueChanged<String> onAnswer;

  @override
  State<AnswerOptions> createState() => _AnswerOptionsState();
}

class _AnswerOptionsState extends State<AnswerOptions> {
  String? _selectedAnswer;

  bool get _isRevealed => _selectedAnswer != null;

  void _select(String answer) {
    if (_isRevealed) return;
    setState(() => _selectedAnswer = answer);
  }

  void _continue() {
    final String? answer = _selectedAnswer;
    if (answer == null) return;
    widget.onAnswer(answer);
    setState(() => _selectedAnswer = null);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final String option in widget.options)
        _OptionTile(
          label: option,
          isSelected: _selectedAnswer == option,
          isCorrect: widget.correctAnswer == option,
          isRevealed: _isRevealed,
          onTap: () => _select(option),
        ),
      if (_isRevealed) ...<Widget>[
        const SizedBox(height: Dimensions.itemHeight10),
        AppElevatedButton(
          text: 'quiz.next'.tr(),
          onPressed: _continue,
          width: double.infinity,
        ),
      ],
    ],
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.isRevealed,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool isRevealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final (Color background, Color foreground, Color border) = switch ((
      isRevealed,
      isCorrect,
      isSelected,
    )) {
      (true, true, _) => (colors.successTint, colors.success, colors.success),
      (true, false, true) => (colors.errorTint, colors.error, colors.error),
      (true, false, false) => (
        colors.surface,
        colors.textSecondary,
        colors.border,
      ),
      _ => (colors.surface, colors.textPrimary, colors.border),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.padding10),
      child: GestureDetector(
        onTap: isRevealed ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.padding10,
            horizontal: Dimensions.padding16,
          ),
          decoration: BoxDecoration(
            color: background,
            border: Border.all(
              color: border,
              width: Dimensions.borderWidthEmphasis,
            ),
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge(foreground),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
