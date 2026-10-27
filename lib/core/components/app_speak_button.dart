import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/speech_cubit.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A circular button that reads [text] aloud through [speech].
///
/// While speaking it fills with the primary colour, shows a stop icon and
/// pulses; tapping it then stops the speech.
class AppSpeakButton extends StatefulWidget {
  const AppSpeakButton({
    super.key,
    required this.speech,
    required this.text,
    this.size = Dimensions.itemHeight44,
    this.iconSize = Dimensions.itemHeight20,
    this.icon = Icons.volume_up_outlined,
    this.idleColor,
    this.pulse = 0.1,
  });

  final SpeechCubit speech;
  final String text;

  /// Diameter of the circle.
  final double size;
  final double iconSize;

  /// Icon shown while idle; a stop icon replaces it during speech.
  final IconData icon;

  /// Background while idle. Defaults to [AppColors.primaryTint].
  final Color? idleColor;

  /// How much the button grows at the peak of its pulse, as a fraction.
  final double pulse;

  @override
  State<AppSpeakButton> createState() => _AppSpeakButtonState();
}

class _AppSpeakButtonState extends State<AppSpeakButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse(isSpeaking: widget.speech.state);
  }

  void _syncPulse({required bool isSpeaking}) {
    if (isSpeaking) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return BlocConsumer<SpeechCubit, bool>(
      bloc: widget.speech,
      listener: (BuildContext context, bool isSpeaking) =>
          _syncPulse(isSpeaking: isSpeaking),
      builder: (BuildContext context, bool isSpeaking) => Semantics(
        button: true,
        child: GestureDetector(
          onTap: () => widget.speech.toggle(widget.text),
          child: ScaleTransition(
            scale: _pulseController.drive(
              Tween<double>(begin: 1, end: 1 + widget.pulse),
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isSpeaking
                      ? colors.primary
                      : widget.idleColor ?? colors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSpeaking ? Icons.stop_rounded : widget.icon,
                  size: widget.iconSize,
                  color: isSpeaking ? colors.onPrimary : colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
