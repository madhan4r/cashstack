import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ergonomic shortcuts used throughout the UI layer — every design-system
/// widget reads colors/text styles through these instead of calling
/// `Theme.of(context)` repeatedly.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;

  /// Success/danger/warning/info/income/expense/shimmer tokens for the
  /// current brightness. See [AppSemanticColors].
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppColors.light;

  Brightness get brightness => Theme.of(this).brightness;

  bool get isDarkMode => brightness == Brightness.dark;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  bool get isKeyboardOpen => viewInsets.bottom > 0;
}
