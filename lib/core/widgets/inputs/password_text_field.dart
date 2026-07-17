import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// [AppTextField] preconfigured for password entry (obscured, with the
/// built-in visibility toggle, a lock icon, and no autocorrect/suggestions).
class PasswordTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  const PasswordTextField({
    super.key,
    this.label = 'Password',
    this.controller,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      validator: validator,
      obscureText: true,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
    );
  }
}
