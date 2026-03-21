import 'package:flutter/material.dart';

import 'routing/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFB71C1C);
    const secondary = Color(0xFFF9A825);
    const surface = Color(0xFF111111);
    const onSurface = Color(0xFFF5F5F5);
    const onPrimary = Colors.white;
    const onSecondary = Colors.black;

    return MaterialApp(
      title: 'CN Pride Point',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: primary,
              brightness: Brightness.dark,
            ).copyWith(
              primary: primary,
              onPrimary: onPrimary,
              secondary: secondary,
              onSecondary: onSecondary,
              surface: surface,
              onSurface: onSurface,
            ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(foregroundColor: onPrimary),
        ),
        scaffoldBackgroundColor: surface,
      ),
      home: const AuthGate(),
    );
  }
}
