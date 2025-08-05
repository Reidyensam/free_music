import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constantes.dart';
import '../../providers/usuario_provider.dart';
import '../../services/servicio_supabase.dart';

class PantallaCrearPlaylist extends ConsumerStatefulWidget {
  const PantallaCrearPlaylist({super.key});

  @override
  ConsumerState<PantallaCrearPlaylist> createState() =>
      _PantallaCrearPlaylistState();
}

class _PantallaCrearPlaylistState extends ConsumerState<PantallaCrearPlaylist> {
  final _formKey = GlobalKey<FormState>();
  String emocionSeleccionada = emociones.first;
  final descripcionCtrl = TextEditingController();

  List<Map<String, String>> canciones = [
    {
      'titulo': '',
      'artista': '',
      'dailymotion_id': '',
      'thumbnail': '',
      'title': ''
    },
  ];

  bool cargando = false;
  bool buscando = false;
  String? error;

  void agregarCancion() {
    setState(() {
      canciones.add({
        'titulo': '',
        'artista': '',
        'dailymotion_id': '',
        'thumbnail': '',
        'title': ''
      });
    });
  }

  void eliminarCancion(int index) {
    setState(() {
      canciones.removeAt(index);
    });
  }

  Future<void> guardarPlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(usuarioProvider);
    if (usuario == null) {
      setState(() => error = 'Debes iniciar sesión');
      return;
    }

    setState(() {
      cargando = true;
      error = null;
    });

    final cancionesValidadas = canciones
        .where((c) => c['titulo']!.isNotEmpty && c['artista']!.isNotEmpty)
        .map((c) => {
              'titulo': c['titulo'],
              'artista': c['artista'],
              'dailymotion_id': c['dailymotion_id'],
            })
        .toList();

    try {
      await ServicioSupabase.cliente.from('playlists_publicas').insert({
        'creator_id': usuario.id,
        'estado_emocional': emocionSeleccionada,
        'descripcion': descripcionCtrl.text,
        'canciones': cancionesValidadas,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'creado_por': usuario.nombreUsuario,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => error = 'Error al guardar: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<List<Map<String, dynamic>>> buscarVideosDailymotion(
      BuildContext context, String query) async {
    final uri = Uri.parse(
      'https://api.dailymotion.com/videos?search=$query&fields=id,title,thumbnail_url&limit=5',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List videos = data['list'];
        if (videos.isEmpty) throw Exception('Sin resultados');
        return videos
            .map<Map<String, dynamic>>((v) => {
                  'id': v['id'],
                  'title': v['title'],
                  'thumbnail': v['thumbnail_url'],
                })
            .toList();
      } else {
        throw Exception('Código ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Modo demo: conexión fallida o sin resultados')),
        );
      }
      return [
        {
          'id': 'demo123',
          'title': 'ERROR DE CONEXIÓN',
          'thumbnail':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Music-icon.png/128px-Music-icon.png',
        },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorDelTema = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Playlist 🎵')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              DropdownButtonFormField<String>(
                value: emocionSeleccionada,
                items: emociones
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => emocionSeleccionada = val!),
                decoration: const InputDecoration(labelText: 'Emoción'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descripcionCtrl,
                decoration:
                    const InputDecoration(labelText: 'Descripción (opcional)'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Canciones', style: TextStyle(fontSize: 16)),
              ...canciones.asMap().entries.map((entry) {
                final i = entry.key;
                final cancion = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: cancion['artista'],
                      decoration: const InputDecoration(labelText: 'Artista'),
                      onChanged: (v) => canciones[i]['artista'] = v,
                    ),
                    TextFormField(
                      initialValue: cancion['titulo'],
                      decoration: InputDecoration(
                          labelText: 'Título de la canción ${i + 1}'),
                      onChanged: (v) => canciones[i]['titulo'] = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 6),
                    buscando
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar en Dailymotion'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorDelTema,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final titulo = canciones[i]['titulo']!;
                              final artista = canciones[i]['artista']!;
                              final query = '$titulo $artista';

                              setState(() => buscando = true);
                              final resultados =
                                  await buscarVideosDailymotion(context, query);
                              setState(() => buscando = false);

                              if (resultados.isEmpty && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('No se encontraron videos')),
                                );
                                return;
                              }

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
                                          Expanded(child: Text(video['title'])),
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
                                  canciones[i]['thumbnail'] =
                                      seleccionado['thumbnail'];
                                  canciones[i]['title'] = seleccionado['title'];
                                });
                              }
                            },
                          ),
                    if (cancion['dailymotion_id']?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Image.network(cancion['thumbnail']!, width: 64),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cancion['title'] ?? '',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (canciones.length > 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => eliminarCancion(i),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Eliminar'),
                        ),
                      ),
                    const Divider(),
                  ],
                );
              }),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Agregar otra canción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorDelTema,
                  foregroundColor: Colors.white,
                ),
                onPressed: agregarCancion,
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                icon: cargando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: cargando
                    ? const Text('Guardando...')
                    : const Text('Guardar Playlist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorDelTema,
                  foregroundColor: Colors.white,
                ),
                onPressed: cargando ? null : guardarPlaylist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
