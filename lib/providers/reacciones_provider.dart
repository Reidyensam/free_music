import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reaccion.dart';

final reaccionesProvider = FutureProvider.family<List<Reaccion>, String>((ref, playlistId) async {
  final response = await Supabase.instance.client
    .from('reacciones_playlist')
    .select()
    .eq('playlist_id', playlistId);

  return response.map((r) => Reaccion.fromMap(r)).toList();
});