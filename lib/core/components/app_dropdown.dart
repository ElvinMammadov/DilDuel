import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A styled dropdown button that opens a [PopupMenu] anchored to its
/// bottom edge.
///
/// [child] is the content rendered inside the styled container.
/// [itemsBuilder] is called with the current [BuildContext] when the user
/// taps the button, so callers can read inherited widgets (e.g. BLoC) at
/// open time.
/// [onSelected] is called with the chosen value.
class AppDropdown<T> extends StatefulWidget {
  final Widget child;
  final List<PopupMenuEntry<T>> Function(BuildContext context) itemsBuilder;
  final ValueChanged<T> onSelected;

  const AppDropdown({
    super.key,
    required this.child,
    required this.itemsBuilder,
    required this.onSelected,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final GlobalKey _anchorKey = GlobalKey();

  Future<void> _openMenu() async {
    final RenderBox? box =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    final T? result = await showMenu<T>(
      context: context,
      color: surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        side: BorderSide(color: border),
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        screenSize.width - (offset.dx + size.width),
        screenSize.height - (offset.dy + size.height),
      ),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
      ),
      items: widget.itemsBuilder(context),
    );

    if (result != null && mounted) {
      widget.onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return GestureDetector(
      onTap: _openMenu,
      child: Container(
        key: _anchorKey,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding12,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          border: Border.all(color: border),
        ),
        child: widget.child,
      ),
    );
  }
}

