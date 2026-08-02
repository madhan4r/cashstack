import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single [RepaintBoundary] key wrapping everything below
/// `MaterialApp.router` (see `app.dart`) — lets any screen trigger a
/// screenshot of exactly what's currently rendered, for feedback reports.
final screenshotBoundaryKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

/// Captures the current app screen as PNG bytes, or `null` if the boundary
/// isn't attached yet (shouldn't happen once the first frame has rendered).
Future<Uint8List?> captureScreenshot(GlobalKey boundaryKey) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;

  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}

/// Holds a screenshot captured by the floating feedback button until the
/// Feedback screen reads (and clears) it — simpler than threading bytes
/// through a GoRouter route.
class PendingFeedbackScreenshot extends Notifier<Uint8List?> {
  @override
  Uint8List? build() => null;

  void set(Uint8List? bytes) => state = bytes;
}

final pendingFeedbackScreenshotProvider =
    NotifierProvider<PendingFeedbackScreenshot, Uint8List?>(
      PendingFeedbackScreenshot.new,
    );
