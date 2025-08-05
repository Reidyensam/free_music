import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:free_music/features/home/widgets/mini_audio_player.dart';

class BibliotecaOffline extends StatefulWidget {
  const BibliotecaOffline({super.key});

  @override
  State<BibliotecaOffline> createState() => _BibliotecaOfflineState();
}

class _BibliotecaOfflineState extends State<BibliotecaOffline> {
  List<FileSystemEntity> archivos = [];

  @override
  void initState() {
    super.initState();
    _cargarArchivos();
  }

  Future<void> _cargarArchivos() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .where((f) =>
            f.path.toLowerCase().endsWith('.mp3') &&
            File(f.path).existsSync())
        .toList();

    for (var f in files) {
      debugPrint('📁 Encontrado: ${f.path}');
    }

    setState(() => archivos = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: archivos.isEmpty
          ? const Center(
              child: Text(
                '🎵 No hay música descargada.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: archivos.length,
              itemBuilder: (context, index) {
                final file = archivos[index];
                final nombreArchivo = file.uri.pathSegments.last;

                if (!nombreArchivo.toLowerCase().endsWith('.mp3')) {
                  return const SizedBox.shrink();
                }

                final id = nombreArchivo.replaceAll('.mp3', '').trim();

                if (id.isEmpty) {
                  return const ListTile(
                    title: Text(
                      '⚠️ Archivo inválido',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: MiniAudioPlayer(
                    urlOnline: '',
                    videoId: id,
                    titulo: id,
                  ),
                );
              },
            ),
    );
  }
}