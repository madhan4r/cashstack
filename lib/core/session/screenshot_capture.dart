import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a screenshot to attach to a feedback report, if one was ever set —
/// nothing currently populates this (the floating capture-and-attach
/// launcher was removed), so the Feedback screen always sees `null`
/// here and submits without a screenshot. Kept as a hook in case a
/// future entry point wants to attach one again.
class PendingFeedbackScreenshot extends Notifier<Uint8List?> {
  @override
  Uint8List? build() => null;

  void set(Uint8List? bytes) => state = bytes;
}

final pendingFeedbackScreenshotProvider =
    NotifierProvider<PendingFeedbackScreenshot, Uint8List?>(
      PendingFeedbackScreenshot.new,
    );
