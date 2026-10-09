part of '../settings.dart';

/// Lets the user report a wrong word or translation, or suggest an idea.
///
/// Opens with [show], which provides its own [FeedbackCubit]. The sheet stays
/// open with the typed text intact when sending fails, so the user can retry.
class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key, this.initialName = ''});

  /// Pre-fills the name field, e.g. with the signed-in user's name.
  final String initialName;

  static Future<void> show(BuildContext context, {String initialName = ''}) =>
      AppBottomSheet.show<void>(
        context,
        isScrollControlled: true,
        child: BlocProvider<FeedbackCubit>(
          create: (_) => sl<FeedbackCubit>(),
          child: FeedbackBottomSheet(initialName: initialName),
        ),
      );

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  final TextEditingController _messageController = TextEditingController();
  bool _nameMissing = false;
  bool _messageMissing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final bool nameMissing = _nameController.text.trim().isEmpty;
    final bool messageMissing = _messageController.text.trim().isEmpty;
    setState(() {
      _nameMissing = nameMissing;
      _messageMissing = messageMissing;
    });
    if (nameMissing || messageMissing) return;
    context.read<FeedbackCubit>().submit(
          name: _nameController.text,
          message: _messageController.text,
        );
  }

  void _onStateChanged(BuildContext context, FeedbackState state) {
    if (state is! FeedbackSent) return;
    final OverlayState? overlay = Navigator.of(context).overlay;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (overlay != null && overlay.mounted) {
        AppSnackbar.showOnOverlay(
          overlay,
          type: SnackbarType.success,
          title: 'settings.feedback.success'.tr(),
          subtitle: 'settings.feedback.success_subtitle'.tr(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: _onStateChanged,
        builder: (BuildContext context, FeedbackState state) {
          final bool isSubmitting = state is FeedbackSubmitting;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: AppBottomSheet(
              title: 'settings.feedback.title'.tr(),
              child: Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.padding20,
                    0,
                    Dimensions.padding20,
                    Dimensions.padding20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppTextField(
                        label: 'settings.feedback.name_label'.tr(),
                        hint: 'settings.feedback.name_hint'.tr(),
                        controller: _nameController,
                        enabled: !isSubmitting,
                        errorText: _nameMissing
                            ? 'settings.feedback.required'.tr()
                            : null,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLength: FeedbackSubmission.nameMaxLength,
                        onChanged: (_) => setState(() => _nameMissing = false),
                      ),
                      const SizedBox(height: Dimensions.itemHeight16),
                      AppTextField(
                        label: 'settings.feedback.message_label'.tr(),
                        hint: 'settings.feedback.message_hint'.tr(),
                        controller: _messageController,
                        enabled: !isSubmitting,
                        errorText: _messageMissing
                            ? 'settings.feedback.required'.tr()
                            : null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 4,
                        maxLines: 6,
                        maxLength: FeedbackSubmission.messageMaxLength,
                        showCounter: true,
                        onChanged: (_) =>
                            setState(() => _messageMissing = false),
                      ),
                      if (state case FeedbackFailed(:final bool isNetworkError))
                        _SendErrorMessage(isNetworkError: isNetworkError),
                      const SizedBox(height: Dimensions.itemHeight20),
                      AppElevatedButton(
                        text: 'settings.feedback.send'.tr(),
                        onPressed: _submit,
                        isLoading: isSubmitting,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _SendErrorMessage extends StatelessWidget {
  const _SendErrorMessage({required this.isNetworkError});

  final bool isNetworkError;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Dimensions.itemHeight10),
        child: Text(
          (isNetworkError
                  ? 'settings.feedback.error_network'
                  : 'settings.feedback.error_generic')
              .tr(),
          style: AppTextStyles.bodySmall(AppColors.of(context).error),
        ),
      );
}
