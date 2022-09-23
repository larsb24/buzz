import 'package:buzz/collections/category.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;

ThemeData get themeData {
  return ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.white,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.black,
      onBackground: Colors.white,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      disabledElevation: 0.0,
      highlightElevation: 0.0,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
    ),
  );
}

Future<void> createIsarDefaultValues(Isar isar) async {
  final categories = await isar.categorys.where().findAll();

  if (categories.isEmpty) {
    await isar.writeTxn(() => isar.categorys.put(Category()..name = "Default"));
  }
}
