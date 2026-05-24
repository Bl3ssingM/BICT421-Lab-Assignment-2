import 'package:flutter/material.dart';
import '../constants.dart';

/// Owns the app-wide theme mode and seed colour.
///
/// By lifting this out of _YummyState and into a ChangeNotifier,
/// any widget deep in the tree can trigger a theme change without
/// needing callbacks passed through every parent.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ColorSelection _colorSelected = ColorSelection.pink;

  // ── Getters ────────────────────────────────────────────────────────────────
  ThemeMode get themeMode => _themeMode;
  ColorSelection get colorSelected => _colorSelected;

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Switches between light and dark mode.
  void changeTheme(bool useLightMode) {
    _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Changes the Material 3 seed colour.
  void changeColor(int index) {
    _colorSelected = ColorSelection.values[index];
    notifyListeners();
  }
}