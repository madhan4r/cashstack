import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/password_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_header.dart';

/// Reached from the link in the password-reset email
/// (`/reset-password?token=...`), or by pasting a token manually if the
/// deep link didn't carry one through.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? initialToken;

  const ResetPasswordScreen({super.key, this.initialToken});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _tokenController = TextEditingController(
    text: widget.initialToken ?? '',
  );
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          token: _tokenController.text.trim(),
          newPassword: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      ok: (_) => setState(() => _submitted = true),
      err: (failure) =>
          ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(
                  title: 'Set a new password',
                  subtitle: _submitted
                      ? 'Your password has been reset. Log in with your new password.'
                      : "Enter the reset code from your email and choose a new password.",
                ),
                const SizedBox(height: 32),
                if (!_submitted) ...[
                  AppTextField(
                    label: 'Reset code',
                    controller: _tokenController,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    validator: (value) =>
                        Validators.required(value, fieldName: 'Reset code'),
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    label: 'New password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    label: 'Confirm new password',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    validator: Validators.confirmPassword(
                      () => _passwordController.text,
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: 'Reset password',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ] else
                  AppPrimaryButton(
                    label: 'Back to login',
                    onPressed: () => context.go(AppRoutes.login),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
