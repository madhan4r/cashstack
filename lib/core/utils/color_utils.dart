import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` / `#AARRGGBB` hex string (as returned by the backend
/// for category/account accent colors) into a [Color]. Returns [fallback]
/// for null/malformed input rather than throwing — a bad accent color
/// should never crash a screen.
Color colorFromHex(String? hex, {required Color fallback}) {
  if (hex == null || hex.isEmpty) return fallback;

  final normalized = hex.replaceFirst('#', '');
  final withAlpha = normalized.length == 6 ? 'FF$normalized' : normalized;
  if (withAlpha.length != 8) return fallback;

  final value = int.tryParse(withAlpha, radix: 16);
  return value == null ? fallback : Color(value);
}
