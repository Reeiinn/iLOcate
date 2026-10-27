import 'package:flutter/material.dart';

/// iLOcate teal, taken from the app logo.
const brandColor = Color(0xFF0B8080);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandColor,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: const CardThemeData(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

/// Pin and label color for each place type, used on the map and in lists.
Color colorForType(String type) {
  switch (type) {
    case 'Food':
      return const Color(0xFFE0592A);
    case 'Cafe':
      return const Color(0xFF8D5B3A);
    case 'Church':
      return const Color(0xFF5B4FA8);
    case 'Museum':
    case 'Heritage':
      return const Color(0xFFB08A1E);
    case 'Mall':
      return const Color(0xFF2B7BBF);
    case 'Beach':
      return const Color(0xFF1AA6A6);
    default:
      return const Color(0xFF5B6A6C);
  }
}
