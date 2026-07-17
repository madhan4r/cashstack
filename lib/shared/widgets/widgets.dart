/// Single import for every design-system widget:
/// `import 'package:cashstack/shared/widgets/widgets.dart';`
///
/// The actual widgets live in `core/widgets/` (they're framework-level,
/// reusable across any feature); this barrel just re-exports them from
/// `shared/` so feature code has one obvious, stable place to import the
/// whole design system from without needing to know the internal
/// buttons/inputs/cards/... subfolder layout.
library;

export '../../core/widgets/widgets.dart';
