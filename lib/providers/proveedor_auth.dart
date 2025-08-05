import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/usuario.dart';
import '../services/servicio_supabase.dart';

final proveedorAuth = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final supa.SupabaseClient _cliente = ServicioSupabase.cliente;

  // Usuario actual (token activo en Supabase)
  supa.User? get usuarioActual => _cliente.auth.currentUser;

  // ✅ Registrar usuario y guardar perfil con tema visual
  Future<supa.AuthResponse> registrar({
    required String email,
    required String password,
    required String username,
    required String temaVisual, // 🌈 nuevo
  }) async {
    final response = await _cliente.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _cliente.from('usuarios').insert({
        'id': response.user!.id,
        'email': email,
        'nombre_usuario': username,
        'rol': 'usuario',
        'tema_visual': temaVisual, // ✨ nuevo campo guardado
      });
    }

    return response;
  }

  // Iniciar sesión
  Future<supa.AuthResponse> iniciarSesion({
    required String email,
    required String password,
  }) {
    return _cliente.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> cerrarSesion() {
    return _cliente.auth.signOut();
  }

  // Obtener el perfil del usuario desde la tabla "usuarios"
  Future<Usuario?> obtenerPerfil() async {
    final id = usuarioActual?.id;
    if (id == null) return null;

    final resultado = await _cliente
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (resultado == null) return null;

    return Usuario.desdeJson(resultado);
  }
}