import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/inputs/password_text_field.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/auth_controller.dart';

/// Change-password for an already-signed-in user (distinct from the
/// forgot/reset-password email flow) — verifies the current password
/// server-side, then signs the user out since the backend invalidates the
/// refresh token on success.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      ok: (_) {
        ref
            .read(snackbarServiceProvider)
            .showSuccess('Password changed. Please log in again.');
        context.go('/login');
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CashStackAppBar(title: 'Change Password'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PasswordTextField(
                  label: 'Current password',
                  controller: _currentPasswordController,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Current password'),
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  label: 'New password',
                  controller: _newPasswordController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  label: 'Confirm new password',
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  validator: Validators.confirmPassword(
                    () => _newPasswordController.text,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'Change Password',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
