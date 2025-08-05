import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:free_music/features/home/widgets/dailymotion_audio.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:free_music/features/home/widgets/reproductor_dailymotion.dart';

class PantallaEditarPlaylist extends StatefulWidget {
  final Map<String, dynamic> data;
  const PantallaEditarPlaylist({super.key, required this.data});

  @override
  State<PantallaEditarPlaylist> createState() => _PantallaEditarPlaylistState();
}

class _PantallaEditarPlaylistState extends State<PantallaEditarPlaylist> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionCtrl;
  late String emocion;
  late List<Map<String, dynamic>> canciones;
  bool cargando = false;
  String? error;

  final List<String> emocionesValidas = [
    '😊 Feliz',
    '🥲 Triste',
    '🌧️ Melancólico',
    '⚡ Motivado',
    '🎧 Relajado',
    '😰 Ansioso',
    '💡 Inspirado',
    '😐 Aburrido',
  ];

  @override
  void initState() {
    super.initState();
    emocion = widget.data['estado_emocional'] ?? emocionesValidas.first;
    if (!emocionesValidas.contains(emocion)) {
      emocion = emocionesValidas.first;
    }

    _descripcionCtrl =
        TextEditingController(text: widget.data['descripcion'] ?? '');

    canciones = List<Map<String, dynamic>>.from(widget.data['canciones'] ?? [])
        .map((c) => {
              'titulo': c['titulo'] ?? '',
              'artista': c['artista'] ?? '',
              'dailymotion_id': c['dailymotion_id'] ?? '',
            })
        .toList();

    if (canciones.isEmpty) {
      canciones.add({'artista': '', 'titulo': '', 'dailymotion_id': ''});
    }
  }

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      cargando = true;
      error = null;
    });

    final cancionesValidas = canciones
        .where((c) => c['titulo']!.isNotEmpty && c['artista']!.isNotEmpty)
        .toList();

    try {
      await Supabase.instance.client.from('playlists_publicas').update({
        'estado_emocional': emocion,
        'descripcion': _descripcionCtrl.text.trim(),
        'canciones': cancionesValidas,
      }).eq('id', widget.data['id']);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => error = 'Error al guardar: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  void agregarCancion() {
    setState(() {
      canciones.add({'titulo': '', 'artista': '', 'dailymotion_id': ''});
    });
  }

  void eliminarCancion(int index) {
    setState(() {
      canciones.removeAt(index);
    });
  }

  Future<List<Map<String, dynamic>>> buscarVideosDailymotion(
      String query) async {
    final uri = Uri.parse(
      'https://api.dailymotion.com/videos?search=$query&fields=id,title,thumbnail_url&limit=5',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List videos = data['list'];
      return videos
          .map<Map<String, dynamic>>((v) => {
                'id': v['id'],
                'title': v['title'],
                'thumbnail': v['thumbnail_url'],
              })
          .toList();
    } else {
      throw Exception('Error al buscar en Dailymotion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Playlist')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.redAccent)),
                DropdownButtonFormField<String>(
                  value: emocion,
                  items: emocionesValidas
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => emocion = val!),
                  decoration: const InputDecoration(labelText: 'Emoción'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Text('Canciones', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                ...canciones.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: c['artista'],
                        decoration: const InputDecoration(labelText: 'Artista'),
                        onChanged: (v) => canciones[i]['artista'] = v,
                      ),
                      TextFormField(
                        initialValue: c['titulo'],
                        decoration:
                            InputDecoration(labelText: 'Título ${i + 1}'),
                        onChanged: (v) => canciones[i]['titulo'] = v,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),

                      // 👥 Botones “Ver video” + “Eliminar” alineados
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar en Dailymotion'),
                            onPressed: () async {
                              final titulo = canciones[i]['titulo']!;
                              final artista = canciones[i]['artista']!;
                              final query = '$titulo $artista';

                              final resultados =
                                  await buscarVideosDailymotion(query);
                              if (!context.mounted) return;

                              final seleccionado =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (_) => SimpleDialog(
                                  title: const Text('Elegí un video'),
                                  children: resultados.map((video) {
                                    return SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.pop(context, video),
                                      child: Row(
                                        children: [
                                          Image.network(video['thumbnail'],
                                              width: 60),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(video['title'],
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );

                              if (seleccionado != null) {
                                setState(() {
                                  canciones[i]['dailymotion_id'] =
                                      seleccionado['id'];
                                });
                              }
                            },
                          ),
                          if (canciones.length > 1)
                            TextButton.icon(
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.red),
                              label: const Text('Eliminar'),
                              onPressed: () => eliminarCancion(i),
                            ),
                        ],
                      ),

                      // 🎥 Previsualización si hay video
                      if (c['dailymotion_id']?.isNotEmpty == true) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Text(
                            '🎥 Video seleccionado: ${c['dailymotion_id']}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.teal),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.play_circle),
                              label: const Text('Ver video'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Previsualizar video'),
                                    content: ReproductorDailymotion(
                                      videoId: c['dailymotion_id'] as String,
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
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.music_note),
                              label: const Text('Reproducir'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Reproduciendo canción'),
                                    content: DailymotionAudioPlayer(
                                      videoUrl:
                                          'https://www.dailymotion.com/video/${c['dailymotion_id']}',
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
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                    ],
                  );
                }),

                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar canción'),
                    onPressed: agregarCancion,
                  ),
                ),

                const SizedBox(
                    height:
                        5), // 👈 Espacio adicional para que “Guardar” no quede abajo
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: cargando
                        ? const Text('Guardando...')
                        : const Text('Guardar'),
                    onPressed: guardarCambios,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
