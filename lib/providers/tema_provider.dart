import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/tema.dart'; // 👈 usamos funciones desde acá

final temaProvider = StateProvider<ThemeData>((ref) {
  return generarTemaDesdeColor(Colors.teal); // función importada, no redefinida
});