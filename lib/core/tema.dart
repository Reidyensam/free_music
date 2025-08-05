import 'package:flutter/material.dart';

/// 🎨 Temas fijos identificados por nombre
final Map<String, ThemeData> temasPorNombre = {
  'Turquesa': ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF007A8A),
    scaffoldBackgroundColor: const Color(0xFFF4FDFD),
    fontFamily: 'Raleway',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF007A8A),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  ),
  'Oscuro': ThemeData.dark().copyWith(
    primaryColor: Colors.blueGrey,
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Raleway'),
    useMaterial3: true,
  ),
  'Cálido': ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.orange.shade700,
    scaffoldBackgroundColor: const Color(0xFFFFF7EC),
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.orange.shade700,
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  ),
};

ThemeData generarTemaDesdeColor(Color color, {bool? forzarModoOscuro}) {
  final brilloCalculado =
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

  final esOscuro = forzarModoOscuro ?? brilloCalculado;

  return ThemeData(
    brightness: esOscuro ? Brightness.dark : Brightness.light,
    primaryColor: color,
    scaffoldBackgroundColor: esOscuro ? const Color(0xFF121212) : Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: color,
      brightness: esOscuro ? Brightness.dark : Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    fontFamily: 'Raleway',
    useMaterial3: true,
  );
}

/// 🔁 Convierte un string HEX guardado en Supabase a Color
Color? colorDesdeHex(String? valorHex) {
  if (valorHex == null || valorHex.isEmpty || !valorHex.startsWith('#'))
    return null;
  try {
    final hex = valorHex.replaceFirst('#', '');
    final intColor = int.parse(hex, radix: 16);
    return Color(intColor);
  } catch (_) {
    return null;
  }
}

/// 🔁 Convierte un Color a un string HEX para guardarlo en Supabase
String colorAHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}
