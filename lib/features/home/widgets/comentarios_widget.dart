import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:free_music/providers/comentarios_provider.dart';
import 'package:free_music/providers/reacciones_provider.dart';
import 'package:intl/intl.dart';

class ComentariosWidget extends ConsumerWidget {
  final String playlistId;
  final String usuarioId;
  final String rolUsuario; // ✅ ¡Acá va!

  const ComentariosWidget({
    super.key,
    required this.playlistId,
    required this.usuarioId,
    required this.rolUsuario, // ✅ también en el constructor
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comentarios = ref.watch(comentariosProvider(playlistId));
    final reacciones = ref.watch(reaccionesProvider(playlistId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),

        // 📝 Botón comentar
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.comment),
            label: const Text('Comentar'),
            onPressed: () {
              final controlador = TextEditingController();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Escribí tu comentario"),
                  content: TextField(
                    controller: controlador,
                    autofocus: true,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "¿Qué pensás de esta playlist?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text("Publicar"),
                      onPressed: () async {
                        final texto = controlador.text.trim();
                        if (texto.isNotEmpty) {
                          final userId =
                              Supabase.instance.client.auth.currentUser?.id;

                          final datos = await Supabase.instance.client
                              .from('usuarios')
                              .select('nombre_usuario')
                              .eq('id', userId!)
                              .maybeSingle();

                          final autorNombre =
                              datos?['nombre_usuario'] ?? 'Anónimo';

                          await Supabase.instance.client
                              .from('comentarios_playlist')
                              .insert({
                            'playlist_id': playlistId,
                            'autor_id': usuarioId,
                            'autor_nombre': autorNombre,
                            'texto': texto,
                          });

                          Navigator.pop(context);
                          ref.invalidate(comentariosProvider(playlistId));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // 💬 Lista de comentarios
        comentarios.when(
          data: (lista) => Column(
            children: lista.map((c) {
              final puedeGestionar =
                  c.autorId == usuarioId || rolUsuario == 'admin';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(c.texto),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🕒 ${DateFormat('HH:mm ').format(c.fecha.toLocal())} — ${DateFormat(' dd-MM-yyyy').format(c.fecha.toLocal())}'),
                    if (c.autorNombre != null)
                      Text('Por: ${c.autorNombre}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 87, 87, 87))),
                  ],
                ),
                trailing: puedeGestionar
                    ? PopupMenuButton<String>(
                        onSelected: (opcion) async {
                          if (opcion == 'editar') {
                            final controlador =
                                TextEditingController(text: c.texto);
                            await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Editar comentario"),
                                content: TextField(controller: controlador),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancelar"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  ElevatedButton(
                                    child: const Text("Guardar"),
                                    onPressed: () async {
                                      await Supabase.instance.client
                                          .from('comentarios_playlist')
                                          .update({
                                        'texto': controlador.text
                                      }).eq('id', c.id);

                                      Navigator.pop(context);
                                      ref.invalidate(
                                          comentariosProvider(playlistId));
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          if (opcion == 'eliminar') {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Eliminar comentario"),
                                content: const Text("¿Estás seguro?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancelar"),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text("Eliminar"),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirmar == true) {
                              await Supabase.instance.client
                                  .from('comentarios_playlist')
                                  .delete()
                                  .eq('id', c.id);
                              ref.invalidate(comentariosProvider(playlistId));
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(
                              value: 'eliminar', child: Text('Eliminar')),
                        ],
                      )
                    : null,
              );
            }).toList(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text("Error al cargar comentarios"),
        ),

        const SizedBox(height: 20),
        // 🎭 Reacciones emocionales (ahora después)
        reacciones.when(
          data: (lista) {
            final actual = lista.firstWhereOrNull(
              (r) => r.usuarioId == usuarioId,
            );
            final actualEmoji = actual?.emoji;

            final conteo = <String, int>{};
            for (var r in lista) {
              conteo[r.emoji] = (conteo[r.emoji] ?? 0) + 1;
            }

            final top = conteo.entries.isNotEmpty
                ? conteo.entries.reduce((a, b) => a.value >= b.value ? a : b)
                : null;

            final listaOrdenada = conteo.entries
                .where((e) => e.value > 0)
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final emojis = ['😍', '😢', '😐', '😎', '🎉'];

            return Column(
              children: [
                // Emojis táctiles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: emojis.map((emoji) {
                    final isSelected = emoji == actualEmoji;

                    return GestureDetector(
                      onTap: () async {
                        if (isSelected) {
                          await Supabase.instance.client
                              .from('reacciones_playlist')
                              .delete()
                              .eq('playlist_id', playlistId)
                              .eq('usuario_id', usuarioId);
                        } else {
                          await Supabase.instance.client
                              .from('reacciones_playlist')
                              .upsert({
                            'playlist_id': playlistId,
                            'usuario_id': usuarioId,
                            'emocion_sentida': emoji,
                          }, onConflict: 'playlist_id, usuario_id');
                        }

                        ref.invalidate(reaccionesProvider(playlistId));
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            emoji,
                            style: TextStyle(
                              fontSize: 28,
                              color:
                                  isSelected ? Colors.blueAccent : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 6),

                if (actualEmoji != null)
                  Text('Tu reacción: $actualEmoji',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 80, 80, 80))),

                const SizedBox(height: 6),

                // Conteo global estilizado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: listaOrdenada.map((entry) {
                    final emoji = entry.key;
                    final cantidad = entry.value;
                    final isTop = top != null && emoji == top.key;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${isTop ? '👑 ' : ''}$emoji $cantidad',
                        style: TextStyle(
                          fontSize: isTop ? 22 : 16,
                          fontWeight:
                              isTop ? FontWeight.bold : FontWeight.normal,
                          color: isTop ? Colors.deepPurple : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 4),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text("Error al cargar reacciones"),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
