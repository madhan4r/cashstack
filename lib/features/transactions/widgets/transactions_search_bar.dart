import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/inputs/search_text_field.dart';

const _debounceDuration = Duration(milliseconds: 400);

/// Search field for the Transactions list — debounces keystrokes so
/// [onSearchChanged] (and therefore a network request) only fires once
/// the user pauses typing, not on every character.
class TransactionsSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const TransactionsSearchBar({super.key, required this.onSearchChanged});

  @override
  State<TransactionsSearchBar> createState() => _TransactionsSearchBarState();
}

class _TransactionsSearchBarState extends State<TransactionsSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _handleChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => widget.onSearchChanged(value));
  }

  void _handleClear() {
    _debounce?.cancel();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return SearchTextField(
      hint: 'Search notes, category, or amount',
      onChanged: _handleChanged,
      onClear: _handleClear,
    );
  }
}
