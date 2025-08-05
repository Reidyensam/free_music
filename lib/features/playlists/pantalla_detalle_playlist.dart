import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_music/features/home/widgets/mini_audio_player.dart';
import 'package:free_music/features/home/widgets/reproductor_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:free_music/features/playlists/pantalla_editar_playlist.dart';
import '../home/widgets/reproductor_dailymotion.dart';
import '../home/widgets/comentarios_widget.dart';
import 'package:free_music/features/home/widgets/dailymotion_audio.dart';


class PantallaDetallePlaylist extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const PantallaDetallePlaylist({super.key, required this.data});

  @override
  ConsumerState<PantallaDetallePlaylist> createState() =>
      _PantallaDetallePlaylistState();
}

class _PantallaDetallePlaylistState
    extends ConsumerState<PantallaDetallePlaylist> {
  String? rolUsuario;
  String? usuarioActualId;
  late String playlistId;
  Map<String, dynamic>? playlistData;
  int? indiceAbierto;
  String modo = '';

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    usuarioActualId = user?.id;
    playlistId = widget.data['id'];
    cargarPlaylist();

    Supabase.instance.client
        .from('usuarios')
        .select('rol')
        .eq('id', usuarioActualId!)
        .maybeSingle()
        .then((data) {
      setState(() {
        rolUsuario = data?['rol'];
      });
    });
  }

  Future<void> cargarPlaylist() async {
    final datos = await Supabase.instance.client
        .from('playlists_publicas')
        .select()
        .eq('id', playlistId)
        .maybeSingle();

    if (mounted) {
      setState(() {
        playlistData = datos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    if (playlistData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final creadorId = playlistData!['creator_id'];
    final puedeEditar = rolUsuario == 'admin' || usuarioActualId == creadorId;

    final emocion = playlistData!['estado_emocional'] ?? 'Sin emoción';
    final descripcion = playlistData!['descripcion'] ?? '';
    final canciones =
        List<Map<String, dynamic>>.from(playlistData!['canciones'] ?? []);
    final fecha =
        playlistData!['fecha_creacion']?.toString().substring(0, 10) ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Emoción: $emocion')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emocion,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (descripcion.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(descripcion),
              ],
              const SizedBox(height: 8),
              Text('🗓️ $fecha', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Text('🎵 Canciones:',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              if (canciones.isEmpty)
                const Text('No hay canciones registradas.')
              else
                ...canciones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final c = entry.value;
                  return Column(
                    children: [
                      VideoToggleUnit(
                        videoId: c['dailymotion_id'] ?? '',
                        titulo: c['titulo'] ?? 'Sin título',
                        artista: c['artista'] ?? '',
                        urlAudio: c['url_audio'] ?? '',
                        estaAbierto: indiceAbierto == index,
                        mostrarAudio: modo == 'audio' && indiceAbierto == index,
                        mostrarVideo: modo == 'video' && indiceAbierto == index,
                        onToggleAudio: () {
                          setState(() {
                            if (indiceAbierto == index && modo == 'audio') {
                              indiceAbierto = null;
                              modo = '';
                            } else {
                              indiceAbierto = index;
                              modo = 'audio';
                            }
                          });
                        },
                        onToggleVideo: () {
                          setState(() {
                            if (indiceAbierto == index && modo == 'video') {
                              indiceAbierto = null;
                              modo = '';
                            } else {
                              indiceAbierto = index;
                              modo = 'video';
                            }
                          });
                        },
                      ),
                      const Divider(),
                    ],
                  );
                }),
              const SizedBox(height: 30),
              if (puedeEditar)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final actualizado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PantallaEditarPlaylist(data: playlistData!),
                            ),
                          );

                          if (actualizado == true && mounted) {
                            await cargarPlaylist();
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('¿Eliminar playlist?'),
                              content: const Text(
                                  'Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            try {
                              await Supabase.instance.client
                                  .from('playlists_publicas')
                                  .delete()
                                  .eq('id', playlistId);
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Error al eliminar la playlist.'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Eliminar'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ),
              ComentariosWidget(
                playlistId: playlistId,
                usuarioId: usuarioActualId ?? '',
                rolUsuario:
                    rolUsuario ?? '', // ✅ Solo admins pueden editar/eliminar
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoToggleUnit extends StatelessWidget {
  final String videoId;
  final String titulo;
  final String artista;
  final String urlAudio;
  final bool estaAbierto;
  final bool mostrarAudio;
  final bool mostrarVideo;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;

  const VideoToggleUnit({
    super.key,
    required this.videoId,
    required this.titulo,
    required this.artista,
    required this.urlAudio,
    required this.estaAbierto,
    required this.mostrarAudio,
    required this.mostrarVideo,
    required this.onToggleAudio,
    required this.onToggleVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎵 Título y artista alineados a la izquierda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      artista,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // 🎬 Botones alineados a la derecha
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onToggleVideo,
                    icon: const Icon(Icons.video_library, size: 18),
                    label: Text(
                      mostrarVideo ? 'Ocultar' : 'Ver Video',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(10, 36),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Reproduciendo Audio'),
                          content: MiniAudioPlayer(
                            urlOnline: getFakeMp3Url(videoId),
                            videoId: videoId,
                            titulo: titulo,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.music_note, size: 18),
                    label: const Text('Reproducir en audio',
                        style: TextStyle(fontSize: 14)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(10, 36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 🎥 Reproductor expandible
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: estaAbierto
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: mostrarAudio
                      ? urlAudio.isNotEmpty
                          ? ReproductorAudio(
                              url: urlAudio,
                              titulo: titulo,
                            )
                          : const Text('🎵 Audio no disponible')
                      : ReproductorDailymotion(videoId: videoId),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
