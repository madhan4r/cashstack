import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/buttons/app_text_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(email: _emailController.text.trim());

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
                  title: 'Reset your password',
                  subtitle: _submitted
                      ? "If an account exists for that email, we've sent a reset link."
                      : "Enter your email and we'll send you a reset link.",
                ),
                const SizedBox(height: 32),
                if (!_submitted) ...[
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.mail_outline),
                    validator: Validators.email,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: 'Send reset link',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ] else ...[
                  AppPrimaryButton(
                    label: 'I have a reset code',
                    onPressed: () => context.push(AppRoutes.resetPassword),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: AppTextButton(
                      label: 'Back to login',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
