import 'package:flutter/material.dart';

/// Fades + slides [child] in, optionally after [delay] — used to stagger
/// the dashboard's sections in on first load without a full animation
/// package. Kept subtle: a short duration and a small slide distance.
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _visible = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
