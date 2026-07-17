import 'package:flutter/material.dart';

/// Standard app bar. Wraps [AppBar] mainly so screens ask for what they
/// need (title, actions, a back button override) without re-specifying
/// `elevation`/`centerTitle`/etc — those already come from
/// [AppBarTheme] in `app_theme.dart`.
class CashStackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const CashStackAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: showBackButton,
      bottom: bottom,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}
