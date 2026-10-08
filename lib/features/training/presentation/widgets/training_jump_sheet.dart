part of training;

/// Bottom sheet that lets the user jump straight to a specific word.
///
/// The target can be chosen by scrubbing the slider, typing a number, or
/// tapping a quick-jump chip. Nothing is persisted until the user confirms,
/// so scrubbing never triggers storage or sync writes.
class JumpToWordSheet extends StatefulWidget {
  const JumpToWordSheet({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.wordAt,
    required this.onJump,
  });

  /// Number of words in the level.
  final int total;

  /// Zero-based index of the word currently shown.
  final int currentIndex;

  /// Returns the word to preview for a zero-based index.
  final String Function(int index) wordAt;

  /// Called with the chosen zero-based index when the user confirms a
  /// different word than [currentIndex].
  final ValueChanged<int> onJump;

  /// Opens the sheet for the word list in [state].
  static Future<void> show(
    BuildContext context, {
    required TrainingReady state,
  }) =>
      AppBottomSheet.show<void>(
        context,
        isScrollControlled: true,
        child: JumpToWordSheet(
          total: state.total,
          currentIndex: state.currentIndex,
          wordAt: (int index) => state.words[index].key,
          onJump: context.read<TrainingCubit>().jumpTo,
        ),
      );

  @override
  State<JumpToWordSheet> createState() => _JumpToWordSheetState();
}

class _JumpToWordSheetState extends State<JumpToWordSheet> {
  static const int _hapticEvery = 10;

  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  late int _selected;

  int get _lastIndex => widget.total - 1;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentIndex;
    _controller = TextEditingController(text: '${_selected + 1}');
    _focusNode.addListener(_restoreTextOnBlur);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_restoreTextOnBlur)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _restoreTextOnBlur() {
    if (!_focusNode.hasFocus) _setText(_selected);
  }

  void _setText(int index) {
    final String text = '${index + 1}';
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _select(int index) {
    final int clamped = index.clamp(0, _lastIndex);
    if (clamped == _selected) return;
    setState(() => _selected = clamped);
    _setText(clamped);
  }

  void _onQuickSelect(int index) {
    HapticFeedback.selectionClick();
    _select(index);
  }

  void _onScrub(double value) {
    final int index = value.round();
    if (index != _selected && index % _hapticEvery == 0) {
      HapticFeedback.selectionClick();
    }
    _select(index);
  }

  void _onTyped(String text) {
    final int? number = int.tryParse(text);
    if (number == null) return;
    final int clamped = number.clamp(1, widget.total);
    setState(() => _selected = clamped - 1);
    if (clamped != number) _setText(_selected);
  }

  void _confirm() {
    Navigator.of(context).pop();
    if (_selected != widget.currentIndex) widget.onJump(_selected);
  }

  @override
  Widget build(BuildContext context) => _SheetFrame(
        child: _JumpSheetContent(
          total: widget.total,
          selected: _selected,
          word: widget.wordAt(_selected),
          controller: _controller,
          focusNode: _focusNode,
          onTyped: _onTyped,
          onScrub: _onScrub,
          onQuickSelect: _onQuickSelect,
          onConfirm: _confirm,
        ),
      );
}

/// Bottom sheet chrome: keyboard-aware padding, title bar and scrolling.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AppBottomSheet(
          title: 'training.jump.title'.tr(),
          child: Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.padding20,
                0,
                Dimensions.padding20,
                Dimensions.padding20,
              ),
              child: child,
            ),
          ),
        ),
      );
}

class _JumpSheetContent extends StatelessWidget {
  const _JumpSheetContent({
    required this.total,
    required this.selected,
    required this.word,
    required this.controller,
    required this.focusNode,
    required this.onTyped,
    required this.onScrub,
    required this.onQuickSelect,
    required this.onConfirm,
  });

  final int total;
  final int selected;
  final String word;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onTyped;
  final ValueChanged<double> onScrub;
  final ValueChanged<int> onQuickSelect;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _JumpHeader(
            total: total,
            word: word,
            index: selected,
            controller: controller,
            focusNode: focusNode,
            onTyped: onTyped,
          ),
          const SizedBox(height: Dimensions.itemHeight8),
          _JumpControls(
            total: total,
            selected: selected,
            onChangeStart: focusNode.unfocus,
            onScrub: onScrub,
            onQuickSelect: onQuickSelect,
          ),
          const SizedBox(height: Dimensions.itemHeight24),
          AppElevatedButton(
            width: double.infinity,
            text: 'training.jump.go'.tr(args: <String>['${selected + 1}']),
            onPressed: onConfirm,
          ),
        ],
      );
}

/// The editable number and the live word preview.
class _JumpHeader extends StatelessWidget {
  const _JumpHeader({
    required this.total,
    required this.word,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onTyped,
  });

  final int total;
  final String word;
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onTyped;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          _NumberField(
            controller: controller,
            focusNode: focusNode,
            total: total,
            onChanged: onTyped,
          ),
          const SizedBox(height: Dimensions.itemHeight8),
          _WordPreview(index: index, word: word),
        ],
      );
}

/// The scrub slider and the quick-jump chips.
class _JumpControls extends StatelessWidget {
  const _JumpControls({
    required this.total,
    required this.selected,
    required this.onChangeStart,
    required this.onScrub,
    required this.onQuickSelect,
  });

  final int total;
  final int selected;
  final VoidCallback onChangeStart;
  final ValueChanged<double> onScrub;
  final ValueChanged<int> onQuickSelect;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          _ScrubSlider(
            value: selected,
            max: total - 1,
            onChangeStart: onChangeStart,
            onChanged: onScrub,
          ),
          const SizedBox(height: Dimensions.itemHeight12),
          _QuickJumpChips(
            selected: selected,
            lastIndex: total - 1,
            onSelected: onQuickSelect,
          ),
        ],
      );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.focusNode,
    required this.total,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int total;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          ListenableBuilder(
            listenable: focusNode,
            builder: (BuildContext context, Widget? field) => _FocusFrame(
              focused: focusNode.hasFocus,
              child: field!,
            ),
            child: _NumberTextField(
              controller: controller,
              focusNode: focusNode,
              maxLength: '$total'.length,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: Dimensions.itemWidth10),
          Text(
            '/ $total',
            style:
                AppTextStyles.titleXLarge(AppColors.of(context).textSecondary),
          ),
        ],
      );
}

/// Tinted rounded box that highlights with a primary border while focused.
class _FocusFrame extends StatelessWidget {
  const _FocusFrame({required this.focused, required this.child});

  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        border: Border.all(
          width: Dimensions.itemWidth2,
          color: focused ? colors.primary : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding20,
          vertical: Dimensions.padding6,
        ),
        child: child,
      ),
    );
  }
}

class _NumberTextField extends StatelessWidget {
  const _NumberTextField({
    required this.controller,
    required this.focusNode,
    required this.maxLength,
    required this.onChanged,
  });

  static const InputDecoration _decoration = InputDecoration(
    isDense: true,
    counterText: '',
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  );

  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: Dimensions.itemWidth64),
        child: Semantics(
          label: 'training.jump.hint'.tr(),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            maxLength: maxLength,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            cursorColor: colors.primary,
            style: AppTextStyles.headlineLarge(colors.primary),
            decoration: _decoration,
          ),
        ),
      ),
    );
  }
}

class _WordPreview extends StatelessWidget {
  const _WordPreview({required this.index, required this.word});

  static const double _fontSize = 20;

  final int index;
  final String word;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: Dimensions.itemHeight32,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          child: Text(
            word,
            key: ValueKey<int>(index),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.wordSource(
              AppColors.of(context).textPrimary,
              size: _fontSize,
            ),
          ),
        ),
      );
}

class _ScrubSlider extends StatelessWidget {
  const _ScrubSlider({
    required this.value,
    required this.max,
    required this.onChangeStart,
    required this.onChanged,
  });

  static const int _overlayAlpha = 32;

  final int value;
  final int max;
  final VoidCallback onChangeStart;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Column(
      children: <Widget>[
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: Dimensions.itemHeight6,
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.border,
            thumbColor: colors.primary,
            overlayColor: colors.primary.withAlpha(_overlayAlpha),
          ),
          child: Slider(
            max: max.toDouble(),
            value: value.toDouble(),
            onChangeStart: (_) => onChangeStart(),
            onChanged: onChanged,
            semanticFormatterCallback: (double v) => '${v.round() + 1}',
          ),
        ),
        _SliderEndLabels(last: max + 1),
      ],
    );
  }
}

class _SliderEndLabels extends StatelessWidget {
  const _SliderEndLabels({required this.last});

  final int last;

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        AppTextStyles.caption(AppColors.of(context).textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('1', style: style),
          Text('$last', style: style),
        ],
      ),
    );
  }
}

class _QuickTarget {
  const _QuickTarget(this.label, this.index);

  final String label;
  final int index;
}

class _QuickJumpChips extends StatelessWidget {
  const _QuickJumpChips({
    required this.selected,
    required this.lastIndex,
    required this.onSelected,
  });

  static const List<double> _fractions = <double>[0.25, 0.5, 0.75];

  final int selected;
  final int lastIndex;
  final ValueChanged<int> onSelected;

  List<_QuickTarget> get _targets => <_QuickTarget>[
        _QuickTarget('training.jump.start'.tr(), 0),
        for (final double fraction in _fractions)
          _QuickTarget(
            '${(fraction * 100).round()}%',
            (lastIndex * fraction).round(),
          ),
        _QuickTarget('training.jump.end'.tr(), lastIndex),
      ];

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: Dimensions.itemWidth8,
        runSpacing: Dimensions.itemHeight8,
        children: <Widget>[
          for (final _QuickTarget target in _targets)
            _QuickChip(
              label: target.label,
              isSelected: target.index == selected,
              onTap: () => onSelected(target.index),
            ),
        ],
      );
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryTint : colors.chipBg,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            isSelected ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
