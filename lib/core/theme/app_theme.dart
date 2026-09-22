import 'package:flutter/material.dart';

class AppTheme {
  // ================= BRAND COLORS =================
  static const Color maroon = Color(0xFF7A1E2D);
  static const Color darkMaroon = Color(0xFF5A1621);

  static const Color lightBg = Color(0xFFF5F6FA);
  static const Color darkBg = Color(0xFF121212);

  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // ================= LIGHT THEME =================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: lightBg,
    primaryColor: maroon,

    colorScheme: ColorScheme.fromSeed(
      seedColor: maroon,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      centerTitle: false,
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: maroon),
      selectedLabelTextStyle:
      const TextStyle(color: maroon, fontWeight: FontWeight.w600),
      unselectedIconTheme:
      const IconThemeData(color: Colors.grey),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: maroon,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),

    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: maroon,
      foregroundColor: Colors.white,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF2E2E2E),
      ),
    ),
  );

  // ================= DARK THEME =================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: darkBg,
    primaryColor: maroon,

    colorScheme: ColorScheme.fromSeed(
      seedColor: maroon,
      brightness: Brightness.dark,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: cardDark,
      elevation: 0,
      foregroundColor: Colors.white,
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: cardDark,
      selectedIconTheme: const IconThemeData(color: maroon),
      selectedLabelTextStyle:
      const TextStyle(color: maroon, fontWeight: FontWeight.w600),
      unselectedIconTheme:
      IconThemeData(color: Colors.grey.shade400),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: maroon,
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: maroon,
      foregroundColor: Colors.white,
    ),
  );
}
