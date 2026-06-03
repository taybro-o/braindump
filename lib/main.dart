// lib/main.dart
//
// ENTRY POINT — BrainDump
// ────────────────────────
// Bootstraps the app with a Material 3 theme and launches HomeScreen.
// Theme uses a deep indigo seed color — change ColorScheme.fromSeed(seedColor)
// to rebrand instantly.

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BrainDumpApp());
}

class BrainDumpApp extends StatelessWidget {
  const BrainDumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainDump',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      // Material 3 dynamic color scheme derived from a single seed color.
      // Both light and dark variants are generated automatically.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3730A3), // indigo-700
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3730A3),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,

      home: const HomeScreen(),
    );
  }
}
