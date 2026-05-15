import 'package:flutter/material.dart';

class AppColors {
  // ── MODO OSCURO ──────────────────────────────────
  static const Color rojo    = Color(0xFFE53935);
  static const Color oscuro  = Color(0xFF121212);
  static const Color oscuro2 = Color(0xFF1E1E1E);
  static const Color blanco  = Colors.white;

  // Estado
  static const Color exito = Colors.green;
  static const Color error = Color(0xFFE53935);
  static const Color info  = Colors.blue;

  // Texto oscuro
  static const Color textoSecundario = Colors.white54;
  static const Color textoTerciario  = Colors.white38;
  static const Color textoPista      = Colors.white24;

  // Bordes oscuro
  static const Color borde      = Colors.white12;
  static const Color bordeSutil = Colors.white24;

  // ── MODO CLARO ───────────────────────────────────
  static const Color claroFondo    = Color(0xFFF5F5F5);
  static const Color claroFondo2   = Color(0xFFFFFFFF);
  static const Color claroTexto    = Color(0xFF1A1A1A);
  static const Color claroBorde    = Color(0xFFE0E0E0);
  static const Color claroBorde2   = Color(0xFFBDBDBD);
  static const Color claroSombra   = Color(0x14000000);
}

// ── TEMA OSCURO ──────────────────────────────────────
ThemeData temaOscuro() {
  return ThemeData(
    brightness:      Brightness.dark,
    useMaterial3:    true,
    scaffoldBackgroundColor: AppColors.oscuro,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.rojo,
      secondary: AppColors.rojo,
      surface:   AppColors.oscuro2,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.oscuro2,
      foregroundColor: AppColors.blanco,
      elevation:       0,
      iconTheme:       IconThemeData(color: AppColors.blanco),
      titleTextStyle:  TextStyle(
        color:      AppColors.blanco,
        fontSize:   18,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.oscuro2,
      selectedItemColor:   AppColors.rojo,
      unselectedItemColor: Colors.white38,
      type:                BottomNavigationBarType.fixed,
      elevation:           8,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.oscuro2,
    ),
    cardTheme: CardThemeData(
      color:  AppColors.oscuro2,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rojo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: AppColors.oscuro2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.rojo),
      ),
      hintStyle:  const TextStyle(color: Colors.white38),
      labelStyle: const TextStyle(color: Colors.white54),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.oscuro2,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Colors.white54, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(color: Colors.white12),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      bodyLarge:   TextStyle(color: Colors.white),
      bodyMedium:  TextStyle(color: Colors.white70),
      bodySmall:   TextStyle(color: Colors.white54),
      titleLarge:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.oscuro2,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.rojo,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.rojo
              : Colors.white38),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.rojo.withValues(alpha: 0.4)
              : Colors.white24),
    ),
  );
}

// ── TEMA CLARO ───────────────────────────────────────
ThemeData temaClaro() {
  return ThemeData(
    brightness:   Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.claroFondo,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.rojo,
      secondary: AppColors.rojo,
      surface:   AppColors.claroFondo2,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.claroFondo2,
      foregroundColor: AppColors.claroTexto,
      elevation:       0,
      shadowColor:     AppColors.claroSombra,
      surfaceTintColor: Colors.transparent,
      iconTheme:       IconThemeData(color: AppColors.claroTexto),
      titleTextStyle:  TextStyle(
        color:      AppColors.claroTexto,
        fontSize:   18,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.claroFondo2,
      selectedItemColor:   AppColors.rojo,
      unselectedItemColor: Color(0xFF9E9E9E),
      type:                BottomNavigationBarType.fixed,
      elevation:           8,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.claroFondo2,
    ),
    cardTheme: CardThemeData(
      color:  AppColors.claroFondo2,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.claroBorde),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rojo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: AppColors.claroFondo2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.claroBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.rojo),
      ),
      hintStyle:  const TextStyle(color: Color(0xFF9E9E9E)),
      labelStyle: const TextStyle(color: Color(0xFF757575)),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.claroFondo2,
      titleTextStyle: TextStyle(
          color: AppColors.claroTexto,
          fontSize: 18,
          fontWeight: FontWeight.bold),
      contentTextStyle:
          TextStyle(color: Color(0xFF616161), fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.claroBorde),
    iconTheme: const IconThemeData(color: Color(0xFF616161)),
    textTheme: const TextTheme(
      bodyLarge:   TextStyle(color: AppColors.claroTexto),
      bodyMedium:  TextStyle(color: Color(0xFF424242)),
      bodySmall:   TextStyle(color: Color(0xFF757575)),
      titleLarge:  TextStyle(
          color: AppColors.claroTexto, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.claroTexto),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.claroTexto,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.rojo,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.rojo
              : Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.rojo.withValues(alpha: 0.4)
              : const Color(0xFFBDBDBD)),
    ),
  );
}
