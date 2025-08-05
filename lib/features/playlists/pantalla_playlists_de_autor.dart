import 'package:flutter/material.dart';
import 'package:free_music/features/home/widgets/tarjeta_playlist.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaPlaylistsDeAutor extends StatelessWidget {
  final String autor;
  const PantallaPlaylistsDeAutor({super.key, required this.autor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Playlists de $autor')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client
            .from('playlists_publicas')
            .select()
            .eq('creado_por', autor)
            .order('fecha_creacion', ascending: false)
            .then((res) => List<Map<String, dynamic>>.from(res)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final listas = snapshot.data ?? [];
          if (listas.isEmpty) {
            return const Center(child: Text('Este autor aún no tiene playlists 😶'));
          }

          return ListView.builder(
            itemCount: listas.length,
            itemBuilder: (context, index) =>
                TarjetaPlaylist(data: listas[index]),
          );
        },
      ),
    );
  }
}