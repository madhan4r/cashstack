import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../extensions/context_extensions.dart';

/// Paints an invisible, off-layout copy of the Dashboard's most expensive
/// draw operations — [BalanceCard]'s blurred gradient shadow,
/// [MonthlyTrendChartCard]'s curved/filled line chart, and [AppCard]'s
/// `Material`/`InkWell` surface (used by every card below the fold —
/// insights, budget, transactions — so it's still new to the first scroll
/// even though [BalanceCard] itself doesn't use it) — so Impeller compiles
/// their GPU pipelines during [SplashScreen]'s network wait instead of on
/// the user's first scroll past the real widgets. Without this, that first
/// scroll eats a one-time hitch while the driver compiles those pipelines
/// on the spot; profiling (Performance Overlay, raster thread) showed every
/// frame after that first one comfortably under budget, so this single
/// warm-up paint is all that's needed — not a resize or a steady-state fix.
///
/// `Opacity(opacity: 0)` (rather than [Offstage]) is deliberate: `Offstage`
/// skips painting entirely, which would skip the very GPU work this exists
/// to trigger.
class DashboardShaderWarmUp extends StatelessWidget {
  const DashboardShaderWarmUp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          width: 1,
          height: 1,
          child: OverflowBox(
            minWidth: 0,
            minHeight: 0,
            maxWidth: 320,
            maxHeight: 220,
            alignment: Alignment.topLeft,
            child: Stack(
              children: [
                Container(
                  width: 320,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusXl,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, Color.lerp(primary, Colors.black, 0.35)!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 320,
                  height: 100,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 10,
                      lineBarsData: [
                        _warmUpLine(Colors.green),
                        _warmUpLine(Colors.red),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                ),
                // Mirrors AppCard: Material surface + InkWell (base ink
                // layer, not just the Container decoration it wraps) plus a
                // circular icon swatch, the shape every category/quick-action
                // icon on the Dashboard uses.
                Positioned(
                  top: 140,
                  child: Material(
                    color: Colors.grey,
                    borderRadius: AppRadius.radiusLg,
                    child: InkWell(
                      borderRadius: AppRadius.radiusLg,
                      onTap: () {},
                      child: Container(
                        width: 200,
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: AppRadius.radiusLg),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.savings_outlined, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _warmUpLine(Color color) {
    return LineChartBarData(
      spots: const [FlSpot(0, 2), FlSpot(1, 6), FlSpot(2, 3), FlSpot(3, 8)],
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
