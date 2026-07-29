import 'package:flutter/material.dart';

/// Exposes the app's current [ThemeMode] and a way to toggle it, to every
/// screen in the tree. Read via `ThemeController.of(context)`.
class ThemeController extends InheritedWidget {
  final ThemeMode mode;
  final VoidCallback toggle;

  const ThemeController({
    super.key,
    required this.mode,
    required this.toggle,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(result != null, 'No ThemeController found in context');
    return result!;
  }

  bool get isDark => mode == ThemeMode.dark;

  @override
  bool updateShouldNotify(ThemeController oldWidget) => mode != oldWidget.mode;
}
