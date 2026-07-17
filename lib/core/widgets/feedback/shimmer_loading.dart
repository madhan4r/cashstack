import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../extensions/context_extensions.dart';

/// Wraps [child] with a moving shimmer highlight — the standard
/// "skeleton loading" effect used while content is being fetched. Wrap any
/// placeholder shape (typically a plain gray [Container]) in this; see
/// [ShimmerBox] for a ready-made placeholder shape, and
/// [ShimmerListPlaceholder] / [ShimmerCardPlaceholder] for common layouts.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({super.key, required this.child, this.isLoading = true});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmerCycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final base = context.semanticColors.shimmerBase;
    final highlight = context.semanticColors.shimmerHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value;
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 - slide * 2, 0),
              end: Alignment(1 - slide * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single placeholder shape — a solid rounded rectangle, typically
/// wrapped in [ShimmerLoading].
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.semanticColors.shimmerBase,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Ready-made shimmering placeholder for a list of tiles (avatar + two
/// lines + trailing value) — e.g. while a transaction list loads.
class ShimmerListPlaceholder extends StatelessWidget {
  final int itemCount;

  const ShimmerListPlaceholder({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return Row(
            children: [
              const ShimmerBox(
                width: 44,
                height: 44,
                borderRadius: AppRadius.radiusPill,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 140, height: 14),
                    SizedBox(height: AppSpacing.xs),
                    ShimmerBox(width: 90, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const ShimmerBox(width: 56, height: 14),
            ],
          );
        },
      ),
    );
  }
}

/// Ready-made shimmering placeholder card — e.g. while a stat/account card
/// loads.
class ShimmerCardPlaceholder extends StatelessWidget {
  final double height;

  const ShimmerCardPlaceholder({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.semanticColors.shimmerBase,
          borderRadius: AppRadius.radiusLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            ShimmerBox(width: 100, height: 12),
            ShimmerBox(width: 160, height: 20),
          ],
        ),
      ),
    );
  }
}
