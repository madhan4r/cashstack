import 'package:flutter/material.dart';

/// Tweens a numeric value from its previous displayed value to [value]
/// whenever it changes, formatting each intermediate frame via [formatter].
/// Used by the summary/insight cards so switching date filters doesn't just
/// snap the numbers — they visibly count up/down.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String Function(double value) formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(formatter(animatedValue), style: style);
      },
    );
  }
}
