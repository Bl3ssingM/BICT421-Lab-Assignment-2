import 'package:flutter/material.dart';

// ── Color theme selector ──────────────────────────────────────────────────────
// Keep your existing ColorSelection enum exactly as-is.
// This is a full copy that also adds YummyTab below.

enum ColorSelection {
  pink(label: 'Pink', color: Colors.pink),
  red(label: 'Red', color: Colors.red),
  orange(label: 'Orange', color: Colors.orange),
  yellow(label: 'Yellow', color: Colors.yellow),
  green(label: 'Green', color: Colors.green),
  blue(label: 'Blue', color: Colors.blue),
  indigo(label: 'Indigo', color: Colors.indigo),
  violet(label: 'Violet', color: Colors.purple);

  const ColorSelection({required this.label, required this.color});

  final String label;
  final Color color;
}

// ── Tab index enum ────────────────────────────────────────────────────────────
// Used by GoRouter to build paths like /<tab>/restaurant/<id>.
// The [value] is the integer that appears in the URL (e.g. /0, /1, /2).
enum YummyTab {
  home(0),
  orders(1),
  account(2);

  const YummyTab(this.value);

  /// The integer path segment used by GoRouter.
  final int value;
}