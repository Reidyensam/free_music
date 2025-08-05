import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tarjeta_playlist.dart';
import '../../../services/servicio_supabase.dart';

/// 🚀 Provider que obtiene todas las playlists públicas
final playlistsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final resultado = await ServicioSupabase.cliente
      .from('playlists_publicas')
      .select()
      .order('fecha_creacion', ascending: false);

  return List<Map<String, dynamic>>.from(resultado);
});

class ListaPlaylists extends ConsumerWidget {
  const ListaPlaylists({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(playlistsProvider);

    return estado.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (playlists) {
        if (playlists.isEmpty) {
          return const Center(child: Text('Aún no hay playlists públicas.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(playlistsProvider); // 🌀 también recarga manual
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              return TarjetaPlaylist(
                key: ValueKey(
                    playlists[index]['id'] ?? playlists[index].hashCode),
                data: playlists[index],
                onActualizar: () async {
                  ref.invalidate(
                      playlistsProvider); // 🔁 recarga al volver de editar
                },
              );
            },
          ),
        );
      },
    );
  }
}
