import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';

/// Themed modal bottom sheet with a drag handle, optional title, and
/// safe-area/keyboard-aware padding. Prefer this over calling
/// `showModalBottomSheet` directly so every sheet in the app gets the same
/// chrome.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
              ],
              // A bare Column child gets unbounded height regardless of
              // the sheet's own (bounded) max height, so a shrinkWrap
              // ListView/GridView here would try to size to ALL of its
              // content and overflow instead of scrolling. Flexible gives
              // it the sheet's real bound to size and scroll within.
              Flexible(child: builder(context)),
            ],
          ),
        ),
      );
    },
  );
}
