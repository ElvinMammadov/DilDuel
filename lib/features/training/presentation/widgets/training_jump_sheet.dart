part of training;

/// Bottom sheet that lets the user jump straight to a specific word.
///
/// The target can be chosen by scrubbing the slider, typing a number, or
/// tapping a quick-jump chip. Nothing is persisted until the user confirms,
/// so scrubbing never triggers storage or sync writes.
class _JumpToWordSheet extends StatefulWidget {
  const _JumpToWordSheet({
    required this.total,
    required this.currentIndex,
    required this.wordAt,
    required this.onJump,
  });

  final int total;
  final int currentIndex;
  final String Function(int index) wordAt;
  final ValueChanged<int> onJump;

  static Future<void> show(
    BuildContext context, {
    required TrainingReady state,
  }) =>
      AppBottomSheet.show<void>(
        context,
        isScrollControlled: true,
        child: _JumpToWordSheet(
          total: state.total,
          currentIndex: state.currentIndex,
          wordAt: (int index) => state.words[index].key,
          onJump: context.read<TrainingCubit>().jumpTo,
        ),
      );

  @override
  State<_JumpToWordSheet> createState() => _JumpToWordSheetState();
}

class _JumpToWordSheetState extends State<_JumpToWordSheet> {
  static const List<double> _quickFractions = <double>[0.25, 0.5, 0.75];
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

  void _select(int index, {bool haptic = false}) {
    final int clamped = index.clamp(0, _lastIndex);
    if (clamped == _selected) return;
    if (haptic) HapticFeedback.selectionClick();
    setState(() => _selected = clamped);
    _setText(clamped);
  }

  void _onScrub(double value) {
    final int index = value.round();
    if (index == _selected) return;
    if (index % _hapticEvery == 0) HapticFeedback.selectionClick();
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _NumberField(
                    controller: _controller,
                    focusNode: _focusNode,
                    total: widget.total,
                    onChanged: _onTyped,
                  ),
                  const SizedBox(height: Dimensions.itemHeight8),
                  _WordPreview(
                    index: _selected,
                    word: widget.wordAt(_selected),
                  ),
                  const SizedBox(height: Dimensions.itemHeight8),
                  _ScrubSlider(
                    value: _selected,
                    max: _lastIndex,
                    onChangeStart: _focusNode.unfocus,
                    onChanged: _onScrub,
                  ),
                  const SizedBox(height: Dimensions.itemHeight12),
                  _QuickJumpChips(
                    selected: _selected,
                    targets: <_QuickTarget>[
                      _QuickTarget('training.jump.start'.tr(), 0),
                      for (final double fraction in _quickFractions)
                        _QuickTarget(
                          '${(fraction * 100).round()}%',
                          (_lastIndex * fraction).round(),
                        ),
                      _QuickTarget('training.jump.end'.tr(), _lastIndex),
                    ],
                    onSelected: (int index) => _select(index, haptic: true),
                  ),
                  const SizedBox(height: Dimensions.itemHeight24),
                  AppElevatedButton(
                    width: double.infinity,
                    text: 'training.jump.go'.tr(args: <String>[
                      '${_selected + 1}',
                    ]),
                    onPressed: _confirm,
                  ),
                ],
              ),
            ),
          ),
        ),
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
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        ListenableBuilder(
          listenable: focusNode,
          builder: (BuildContext context, Widget? child) => DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              border: Border.all(
                width: Dimensions.itemWidth2,
                color: focusNode.hasFocus ? colors.primary : Colors.transparent,
              ),
            ),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding20,
              vertical: Dimensions.padding6,
            ),
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: Dimensions.itemWidth64),
                child: Semantics(
                  label: 'training.jump.hint'.tr(),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: '$total'.length,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    cursorColor: colors.primary,
                    style: AppTextStyles.headlineLarge(colors.primary),
                    decoration: const InputDecoration(
                      isDense: true,
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.itemWidth10),
        Text(
          '/ $total',
          style: AppTextStyles.titleXLarge(colors.textSecondary),
        ),
      ],
    );
  }
}

class _WordPreview extends StatelessWidget {
  const _WordPreview({required this.index, required this.word});

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
              size: Dimensions.itemHeight20,
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
            overlayColor: colors.primary.withAlpha(32),
          ),
          child: Slider(
            max: max.toDouble(),
            value: value.toDouble(),
            onChangeStart: (_) => onChangeStart(),
            onChanged: onChanged,
            semanticFormatterCallback: (double v) => '${v.round() + 1}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('1', style: AppTextStyles.caption(colors.textSecondary)),
              Text(
                '${max + 1}',
                style: AppTextStyles.caption(colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
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
    required this.targets,
    required this.onSelected,
  });

  final int selected;
  final List<_QuickTarget> targets;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Dimensions.itemWidth8,
      runSpacing: Dimensions.itemHeight8,
      children: <Widget>[
        for (final _QuickTarget target in targets)
          GestureDetector(
            onTap: () => onSelected(target.index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding16,
                vertical: Dimensions.padding8,
              ),
              decoration: BoxDecoration(
                color: target.index == selected
                    ? colors.primaryTint
                    : colors.chipBg,
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
                border: Border.all(
                  color: target.index == selected
                      ? colors.primary
                      : Colors.transparent,
                ),
              ),
              child: Text(
                target.label,
                style: AppTextStyles.labelMedium(
                  target.index == selected
                      ? colors.primary
                      : colors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
