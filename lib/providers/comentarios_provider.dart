import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comentario.dart';

final comentariosProvider = StreamProvider.family<List<Comentario>, String>((ref, playlistId) {
  return Supabase.instance.client
    .from('comentarios_playlist')
    .stream(primaryKey: ['id'])
    .eq('playlist_id', playlistId)
    .order('fecha_creacion', ascending: false)
    .map((rows) => rows.map((r) => Comentario.fromMap(r)).toList());
});