import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// Sun/moon icon button that flips the app between light and dark mode.
/// Drop it anywhere — it reads [ThemeController] from context.
class ThemeToggleButton extends StatelessWidget {
  final Color? color;

  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    return IconButton(
      tooltip: controller.isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: controller.toggle,
      icon: Icon(
        controller.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: color,
        size: 20,
      ),
    );
  }
}
