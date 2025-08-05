import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicioSupabase {
  static Future<void> iniciar() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  static SupabaseClient get cliente => Supabase.instance.client;

  static Future<void> crearPlaylistPublica({
    required String titulo,
    required String descripcion,
    required String estadoEmocional,
    required List<String> canciones,
    required String creadoPor,
  }) async {
    final data = {
      'titulo': titulo,
      'descripcion': descripcion,
      'estado_emocional': estadoEmocional,
      'canciones': canciones,
      'creado_por': creadoPor,
    };

    try {
      await cliente.from('playlists_publicas').insert(data);
      debugPrint('✅ Playlist creada correctamente');
    } catch (e) {
      debugPrint('❌ Error al crear playlist: $e');
    }
  }
}
