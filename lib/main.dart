import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.restore();
  runApp(const MamaSafeApp());
}

class MamaSafeApp extends StatefulWidget {
  const MamaSafeApp({super.key});

  @override
  State<MamaSafeApp> createState() => _MamaSafeAppState();
}

class _MamaSafeAppState extends State<MamaSafeApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggle() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      mode: _mode,
      toggle: _toggle,
      child: MaterialApp.router(
        title: 'MamaPreCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mode,
        routerConfig: appRouter,
      ),
    );
  }
}
