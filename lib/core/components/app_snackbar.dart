import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// Semantic variant shown by [AppSnackbar].
enum SnackbarType { success, error, warning, info }

/// A single, optional inline action rendered at the end of a snackbar.
class SnackbarAction {
  const SnackbarAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// App-branded replacement for the default Material [SnackBar].
///
/// Shows a floating, auto-dismissing notification via [Overlay] so its
/// look (colors, radii, animation) stays fully under app control. Calling
/// [show] again while one is visible replaces it immediately.
class AppSnackbar {
  AppSnackbar._();

  static const Duration _displayDuration = Duration(milliseconds: 3000);
  static const Duration _enterDuration = Duration(milliseconds: 320);
  static const Duration _exitDuration = Duration(milliseconds: 220);

  static final GlobalKey<_AppSnackbarWidgetState> _contentKey =
      GlobalKey<_AppSnackbarWidgetState>();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required SnackbarType type,
    required String title,
    String? subtitle,
    SnackbarAction? action,
    Duration duration = _displayDuration,
  }) =>
      _insert(
        Overlay.of(context),
        type: type,
        title: title,
        subtitle: subtitle,
        action: action,
        duration: duration,
      );

  static void showOnOverlay(
    OverlayState overlay, {
    required SnackbarType type,
    required String title,
    String? subtitle,
    SnackbarAction? action,
    Duration duration = _displayDuration,
  }) =>
      _insert(
        overlay,
        type: type,
        title: title,
        subtitle: subtitle,
        action: action,
        duration: duration,
      );

  static void _insert(
    OverlayState overlay, {
    required SnackbarType type,
    required String title,
    String? subtitle,
    SnackbarAction? action,
    Duration duration = _displayDuration,
  }) {
    _removeImmediately();

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext _) => _AppSnackbarWidget(
        key: _contentKey,
        type: type,
        title: title,
        subtitle: subtitle,
        action: action,
        enterDuration: _enterDuration,
        exitDuration: _exitDuration,
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, dismiss);
  }

  /// Plays the exit animation, then removes the snackbar from the overlay.
  static void dismiss() {
    _timer?.cancel();
    final _AppSnackbarWidgetState? state = _contentKey.currentState;
    if (state == null) {
      _removeImmediately();
      return;
    }
    state.animateOut(_removeImmediately);
  }

  static void _removeImmediately() {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;
  }
}

class _AppSnackbarWidget extends StatefulWidget {
  const _AppSnackbarWidget({
    super.key,
    required this.type,
    required this.title,
    required this.enterDuration,
    required this.exitDuration,
    this.subtitle,
    this.action,
  });

  final SnackbarType type;
  final String title;
  final String? subtitle;
  final SnackbarAction? action;
  final Duration enterDuration;
  final Duration exitDuration;

  @override
  State<_AppSnackbarWidget> createState() => _AppSnackbarWidgetState();
}

class _AppSnackbarWidgetState extends State<_AppSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.enterDuration,
      reverseDuration: widget.exitDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _controller.forward();
  }

  void animateOut(VoidCallback onComplete) {
    _controller.reverse().whenComplete(onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.of(context).padding;

    return Positioned(
      left: Dimensions.padding16,
      right: Dimensions.padding16,
      bottom: Dimensions.padding24 + viewPadding.bottom,
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            final double t = _animation.value;
            return Transform.translate(
              offset: Offset(0, (1 - t) * Dimensions.padding80),
              child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
            );
          },
          child: _SnackbarCard(
            type: widget.type,
            title: widget.title,
            subtitle: widget.subtitle,
            action: widget.action,
            onDismissTap: AppSnackbar.dismiss,
          ),
        ),
      ),
    );
  }
}

class _SnackbarCard extends StatelessWidget {
  const _SnackbarCard({
    required this.type,
    required this.title,
    required this.onDismissTap,
    this.subtitle,
    this.action,
  });

  final SnackbarType type;
  final String title;
  final String? subtitle;
  final SnackbarAction? action;
  final VoidCallback onDismissTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final (Color iconBg, Color iconColor, IconData icon) = switch (type) {
      SnackbarType.success => (
          colors.successTint,
          colors.success,
          Icons.check_rounded,
        ),
      SnackbarType.error => (
          colors.errorTint,
          colors.error,
          Icons.close_rounded,
        ),
      SnackbarType.warning => (
          colors.warningTint,
          colors.warning,
          Icons.priority_high_rounded,
        ),
      SnackbarType.info => (
          colors.infoTint,
          colors.info,
          Icons.info_rounded,
        ),
    };

    return Semantics(
      container: true,
      liveRegion: true,
      label: subtitle == null ? title : '$title. $subtitle',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding14,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusLarge),
          border: Border.all(color: isDark ? colors.border : colors.chipBg),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : const Color(0xFF1B1730).withValues(alpha: 0.14),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: Dimensions.itemWidth38,
              height: Dimensions.itemHeight38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              ),
              child:
                  Icon(icon, size: Dimensions.itemHeight18, color: iconColor),
            ),
            const SizedBox(width: Dimensions.padding12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.labelLarge(colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: Dimensions.itemHeight2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption(colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (action != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.spacingSmall),
                child: GestureDetector(
                  onTap: action!.onPressed,
                  child: Text(
                    action!.label,
                    style: AppTextStyles.labelMedium(iconColor),
                  ),
                ),
              ),
            GestureDetector(
              onTap: onDismissTap,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.spacingSmall),
                child: Icon(
                  Icons.close_rounded,
                  size: Dimensions.itemHeight16,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
