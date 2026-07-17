/// 8-point spacing scale. Every gap/padding in the app should come from
/// here instead of a magic number, so rhythm stays consistent.
class AppSpacing {
  const AppSpacing._();

  static const double none = 0;

  /// 4 — half-step, for tight groupings (icon-to-label, chip padding).
  static const double xs = 4;

  /// 8 — the base unit.
  static const double sm = 8;

  /// 16 — default content padding/gap.
  static const double md = 16;

  /// 24 — section-level spacing.
  static const double lg = 24;

  /// 32 — screen-edge / large section spacing.
  static const double xl = 32;

  /// 48 — hero/empty-state spacing.
  static const double xxl = 48;

  /// 64 — rare, large vertical rhythm (e.g. splash layouts).
  static const double xxxl = 64;
}
