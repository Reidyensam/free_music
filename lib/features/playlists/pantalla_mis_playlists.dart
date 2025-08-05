import 'package:flutter/material.dart';
import 'package:free_music/features/playlists/pantalla_playlists_de_autor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:free_music/features/playlists/pantalla_detalle_playlist.dart';

class PantallaMisPlaylists extends StatefulWidget {
  const PantallaMisPlaylists({super.key});

  @override
  State<PantallaMisPlaylists> createState() => _PantallaMisPlaylistsState();
}

class _PantallaMisPlaylistsState extends State<PantallaMisPlaylists>
    with SingleTickerProviderStateMixin {
  late String uid;
  String? rol;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    assert(user != null, 'Usuario no autenticado');
    uid = user!.id;

    Supabase.instance.client
        .from('usuarios')
        .select()
        .eq('id', uid)
        .maybeSingle()
        .then((data) {
      rol = data?['rol'];
      _tabController = TabController(length: esAdmin ? 2 : 1, vsync: this);
      setState(() {});
    });
  }

  bool get esAdmin => rol == 'admin';

  @override
  Widget build(BuildContext context) {
    if (rol == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Playlists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: '🟦 Mis playlists'),
            if (esAdmin) const Tab(text: '🟪 Todas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PlaylistList(filtrarPorUsuario: uid),
          if (esAdmin) const _PlaylistList(filtrarPorUsuario: null),
        ],
      ),
    );
  }
}

class _PlaylistList extends StatelessWidget {
  final String? filtrarPorUsuario;

  const _PlaylistList({this.filtrarPorUsuario});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: () async {
        final supabase = Supabase.instance.client;

        var query = supabase
            .from('playlists_publicas')
            .select('*, usuarios(nombre_usuario)');

        if (filtrarPorUsuario != null) {
          query = query.eq('creator_id', filtrarPorUsuario!);
        }

        final resultado = await query.order('fecha_creacion', ascending: false);
        return List<Map<String, dynamic>>.from(resultado);
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final playlists = snapshot.data ?? [];
        if (playlists.isEmpty) {
          return const Center(child: Text('No hay playlists 😶'));
        }

        return ListView.separated(
          itemCount: playlists.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (_, index) {
            final p = playlists[index];

            final rawTitulo = (p['titulo'] as String?)?.trim();
            final mostrarTitulo = (rawTitulo == null || rawTitulo.isEmpty)
                ? 'Sin título'
                : rawTitulo;

            final canciones = (p['canciones'] as List<dynamic>?) ?? [];
            final subtitleTexto = mostrarTitulo == 'Sin título'
                ? '${canciones.length} canción${canciones.length == 1 ? '' : 'es'}'
                : mostrarTitulo;

            final creadorId = p['creator_id'];
final creadorNombre = p['usuarios']?['nombre_usuario'];
final creadoPor = p['creado_por']; // respaldo directo

final autorTexto = creadoPor ?? creadorNombre;

final creador = (creadorId == Supabase.instance.client.auth.currentUser?.id)
    ? 'Ti'
    : (autorTexto?.isNotEmpty == true ? autorTexto : 'Alguien');

            return ListTile(
              title: Text(p['estado_emocional'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitleTexto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Si es "TÍ", no navegamos
                      if (creador.toLowerCase() == 'Ti') return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaPlaylistsDeAutor(
                              autor: autorTexto ?? ''),
                        ),
                      );
                    },
                    child: Text(
                      '👤 Creado Por $creador',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Text(
                p['fecha_creacion']?.toString().substring(0, 10) ?? '',
                style: const TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaDetallePlaylist(data: p),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
