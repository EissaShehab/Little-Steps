import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'themeMode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      state = AppThemeMode.values[index];
    } catch (e) {
      state = AppThemeMode.system;
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  final isDark = _shouldUseDarkTheme(themeMode);

  // Core colors
  final lightBlue = const Color(0xFF42A5F5); // Softer light blue
  final darkBlue = const Color(0xFF1976D2); // Rich dark blue

  // Feature-specific accent colors
  final growthAccent = const Color(0xFFFFCA28); // Soft yellow for growth
  final vaccinationAccent = const Color(0xFF4CAF50); // Green for vaccinations
  final symptomAccent = const Color(0xFFE57373); // Soft red for symptoms

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: isDark ? darkBlue : lightBlue,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: isDark ? darkBlue : lightBlue,
      secondary: vaccinationAccent,
      tertiary: growthAccent, // For growth-related features
      error: symptomAccent, // For symptom-related features
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? darkBlue : lightBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 28,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
      bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
      bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black54),
    ).apply(
      displayColor: isDark ? Colors.white : Colors.black87,
      bodyColor: isDark ? Colors.white70 : Colors.black54,
    ),
  );
});

bool _shouldUseDarkTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
  }
}