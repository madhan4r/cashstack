/// Shared form-field validators. Kept UI-framework-agnostic (plain
/// `String? Function(String?)`) so they work directly as
/// `TextFormField.validator`.
class Validators {
  const Validators._();

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Full name is required';
    }
    if (trimmed.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String? Function() getOriginalPassword,
  ) {
    return (value) {
      if (value != getOriginalPassword()) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if ((value ?? '').trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
