/// Standard animation durations/curves so transitions feel consistent
/// (bottom sheets, shimmer, snackbars, dialogs).
class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Duration shimmerCycle = Duration(milliseconds: 1400);
  static const Duration snackbar = Duration(seconds: 3);
  static const Duration toast = Duration(seconds: 2);
}
