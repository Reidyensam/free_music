import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_music/features/playlists/pantalla_detalle_playlist.dart';
import 'package:free_music/features/playlists/pantalla_playlists_de_autor.dart';
import 'package:free_music/providers/reacciones_provider.dart';

String formatearFechaLatina(String isoDate) {
  final meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  try {
    final date = DateTime.parse(isoDate);
    final dia = date.day;
    final mes = meses[date.month - 1];
    final anio = date.year;
    return '$dia $mes $anio';
  } catch (_) {
    return isoDate;
  }
}

Color obtenerColorFondo(String emocion) {
  switch (emocion.trim()) {
    case '😊 Feliz': return Colors.yellow.shade50;
    case '🥲 Triste': return Colors.blue.shade50;
    case '🌧️ Melancólico': return Colors.grey.shade200;
    case '⚡ Motivado': return Colors.orange.shade50;
    case '🎧 Relajado': return Colors.green.shade50;
    case '😰 Ansioso': return Colors.purple.shade50;
    case '💡 Inspirado': return Colors.amber.shade50;
    case '😐 Aburrido': return Colors.brown.shade50;
    default: return Colors.white;
  }
}

IconData obtenerIcono(String emocion) {
  final mapa = {
    '😊 Feliz': Icons.emoji_emotions,
    '🥲 Triste': Icons.emoji_emotions_outlined,
    '🌧️ Melancólico': Icons.cloud,
    '⚡ Motivado': Icons.flash_on,
    '🎧 Relajado': Icons.self_improvement,
    '😰 Ansioso': Icons.airline_seat_flat,
    '💡 Inspirado': Icons.lightbulb,
    '😐 Aburrido': Icons.sentiment_dissatisfied,
  };
  return mapa[emocion.trim()] ?? Icons.music_note;
}

String? obtenerEmojiDominante(List<dynamic> lista) {
  final conteo = <String, int>{};
  for (var r in lista) {
    conteo[r.emoji] = (conteo[r.emoji] ?? 0) + 1;
  }
  if (conteo.isEmpty) return null;
  String topEmoji = '';
  int max = 0;
  conteo.forEach((emoji, count) {
    if (count > max) {
      max = count;
      topEmoji = emoji;
    }
  });
  return topEmoji;
}

class TarjetaPlaylist extends ConsumerWidget {
  final Map<String, dynamic> data;
  final Future<void> Function()? onActualizar;

  const TarjetaPlaylist({
    super.key,
    required this.data,
    this.onActualizar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emocion = data['estado_emocional'] ?? 'Sin emoción';
    final fecha = formatearFechaLatina(data['fecha_creacion']?.toString() ?? '');
    final descripcion = data['descripcion'] ?? '';
    final canciones = data['canciones'] as List<dynamic>? ?? [];
    final autor = data['creado_por'] ?? 'Anónimo';
    final playlistId = data['id'];

    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorFondo = esOscuro ? Colors.grey.shade900 : obtenerColorFondo(emocion);

    final reaccionesAsync = ref.watch(reaccionesProvider(playlistId));
    final emojiDominante = reaccionesAsync.when(
      data: obtenerEmojiDominante,
      loading: () => null,
      error: (_, __) => null,
    );

    return Card(
      color: colorFondo,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        splashColor: Colors.teal.shade50,
        onTap: () async {
          final actualizado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaDetallePlaylist(data: data),
            ),
          );
          if (actualizado == true && context.mounted) {
            await onActualizar?.call();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎭 Encabezado emocional
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(obtenerIcono(emocion), color: Colors.teal.shade800),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        emocion,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fecha,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (emojiDominante != null)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            emojiDominante,
                            key: ValueKey(emojiDominante),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 1),

              // 💬 Descripción
              Text(
                descripcion.isEmpty ? 'Sin descripción' : descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 1),

              // 👥 Autor y 🎵 canciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaPlaylistsDeAutor(autor: autor),
                        ),
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Semantics(
                        label: 'Playlist creada por $autor',
                        child: Text(
                          'Por: $autor',
                          key: ValueKey(autor),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.library_music, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${canciones.length} canciones',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}