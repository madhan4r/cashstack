/// Shared sizing tokens across every button variant.
enum AppButtonSize {
  small(height: 40),
  medium(height: 52),
  large(height: 58);

  final double height;

  const AppButtonSize({required this.height});
}
