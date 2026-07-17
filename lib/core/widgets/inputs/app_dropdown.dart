import 'package:flutter/material.dart';

/// Generic, themed dropdown. Pass any `T` plus a [labelBuilder] — no
/// coupling to a specific model, so it works for categories, accounts,
/// filters, anything.
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final Widget Function(T item)? iconBuilder;
  final void Function(T? value)? onChanged;
  final String? Function(T? value)? validator;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    this.iconBuilder,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconBuilder != null) ...[
                    iconBuilder!(item),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      labelBuilder(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
