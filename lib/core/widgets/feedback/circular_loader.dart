import 'package:flutter/material.dart';

/// The bare spinner primitive — used standalone (inline in a row, inside a
/// button) or composed into [LoadingWidget] for a full state view.
class CircularLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const CircularLoader({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
