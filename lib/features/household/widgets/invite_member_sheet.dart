import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../services/snackbar_service.dart';
import '../providers/household_controller.dart';

/// Shows a sheet to invite someone by email into the caller's household —
/// returns once the invite request has actually been sent (or the sheet
/// was dismissed).
Future<void> showInviteMemberSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    title: 'Invite to Household',
    builder: (context) => const _InviteMemberForm(),
  );
}

class _InviteMemberForm extends ConsumerStatefulWidget {
  const _InviteMemberForm();

  @override
  ConsumerState<_InviteMemberForm> createState() => _InviteMemberFormState();
}

class _InviteMemberFormState extends ConsumerState<_InviteMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(householdControllerProvider.notifier)
        .invite(_emailController.text.trim());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      ok: (_) {
        Navigator.of(context).pop();
        ref.read(snackbarServiceProvider).showSuccess('Invite sent');
      },
      err: (failure) =>
          ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "They'll see this the next time they open CashStack signed in with "
            "that email — or the moment they sign up with it, if they don't "
            'have an account yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(
            label: 'Send Invite',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
