import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/session/screenshot_capture.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../repositories/feedback_repository.dart';

/// Reached via the floating feedback button (see `app.dart`), which
/// captures a screenshot of whatever screen the user was on and stashes it
/// in [pendingFeedbackScreenshotProvider] before navigating here.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _includeScreenshot = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit(Uint8List? screenshot) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(feedbackRepositoryProvider).submit(
          message: _messageController.text.trim(),
          screenshot: _includeScreenshot ? screenshot : null,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      ok: (_) {
        ref.read(pendingFeedbackScreenshotProvider.notifier).set(null);
        ref.read(snackbarServiceProvider).showSuccess('Thanks for the feedback!');
        context.pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenshot = ref.watch(pendingFeedbackScreenshotProvider);

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Send Feedback'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Found a bug or have a suggestion? Let us know below.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Your feedback',
                  controller: _messageController,
                  maxLines: 5,
                  maxLength: 2000,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Feedback'),
                ),
                if (screenshot != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text('Attach screenshot', style: context.textStyles.titleSmall),
                      const Spacer(),
                      Switch(
                        value: _includeScreenshot,
                        onChanged: (value) => setState(() => _includeScreenshot = value),
                      ),
                    ],
                  ),
                  if (_includeScreenshot) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(screenshot, fit: BoxFit.cover),
                    ),
                  ],
                ],
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: 'Send Feedback',
                  isLoading: _isSubmitting,
                  onPressed: () => _submit(screenshot),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
