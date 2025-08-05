import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';


class MiniAudioPlayer extends StatefulWidget {
  final String urlOnline;
  final String videoId;
  final String titulo;

  const MiniAudioPlayer({
    super.key,
    required this.urlOnline,
    required this.videoId,
    required this.titulo,
  });

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  bool _preparado = false;
  String? _localPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _prepare();

    _player.durationStream.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d ?? Duration.zero);
    });

    _player.positionStream.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });
  }

  Future<void> _prepare() async {
    if (widget.videoId.trim().isEmpty) {
      debugPrint('❌ videoId vacío');
      return;
    }

    final dir = Directory('/storage/emulated/0/Download/FreeMusic');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final path = '${dir.path}/${widget.videoId}.mp3';
    final file = File(path);

    if (!mounted) return;
    setState(() {
      _localPath = path;
      _isDownloaded = file.existsSync();
      _preparado = true;
    });
  }

  Future<void> _togglePlay() async {
    if (!_preparado || _localPath == null) return;

    AudioSource source;

    if (_isDownloaded && File(_localPath!).existsSync()) {
      source = AudioSource.uri(Uri.file(_localPath!));
    } else if (widget.urlOnline.isNotEmpty) {
      source = AudioSource.uri(Uri.parse(widget.urlOnline));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No se encontró el archivo de audio')),
      );
      return;
    }

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.setAudioSource(source);
      await _player.play();
    }

    if (!mounted) return;
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _downloadAudio() async {
    if (!_preparado) return;

    try {
      // ✅ Pedir solo el permiso especial
      final permisoGestion = await Permission.manageExternalStorage.request();
      debugPrint('📦 Manage External Storage: $permisoGestion');

      // ✅ Si fue denegado permanentemente, abrir configuración
      if (permisoGestion.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ Permiso denegado permanentemente. Abrí la configuración.'),
          ),
        );
        await openAppSettings();

        // Esperar a que el usuario vuelva y verificar en bucle
        bool permisoConcedido = false;
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(seconds: 1));
          final estado = await Permission.manageExternalStorage.status;
          if (estado.isGranted) {
            permisoConcedido = true;
            break;
          }
        }

        if (!permisoConcedido) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('❌ El permiso sigue sin estar activo')),
          );
          return;
        }
      }

      // ✅ Si aún no está concedido, mostrar botón para abrir configuración
      if (!permisoGestion.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '⚠️ Necesitás habilitar “Acceso a todos los archivos”'),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
        return;
      }

      setState(() => _isDownloading = true);

      // ✅ Descargar el archivo
      final response = await http.get(Uri.parse(widget.urlOnline));

      // ✅ Crear carpeta pública si no existe
      final dir = Directory('/storage/emulated/0/Download/FreeMusic');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final path = '${dir.path}/${widget.videoId}.mp3';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      setState(() {
        _localPath = path;
        _isDownloaded = true;
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Guardado en: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al descargar: $e')),
      );
    }
  }

  Future<void> _deleteAudio() async {
    if (!_preparado || _localPath == null) return;
    final file = File(_localPath!);
    if (await file.exists()) {
      await file.delete();
      if (!mounted) return;
      setState(() => _isDownloaded = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Archivo eliminado')),
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoId.trim().isEmpty) {
      return Card(
        margin: const EdgeInsets.only(top: 8),
        color: Colors.red[900],
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            '⚠️ ID de audio inválido',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_localPath == null || (!_isDownloaded && widget.urlOnline.isEmpty)) {
      return Card(
        margin: const EdgeInsets.only(top: 8),
        color: Colors.red[900],
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            '⚠️ Archivo de audio no disponible',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _preparado ? _togglePlay : null,
                ),
                Expanded(
                  child: Text(widget.titulo, overflow: TextOverflow.ellipsis),
                ),
                if (_isDownloading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_isDownloaded)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteAudio,
                    tooltip: 'Eliminar archivo',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _preparado ? _downloadAudio : null,
                    tooltip: 'Descargar',
                  ),
              ],
            ),
            if (_duration > Duration.zero)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Column(
                  children: [
                    Slider(
                      value: _position.inMilliseconds
                          .clamp(0, _duration.inMilliseconds)
                          .toDouble(),
                      max: _duration.inMilliseconds.toDouble(),
                      onChanged: (value) async {
                        await _player
                            .seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position),
                            style: const TextStyle(fontSize: 12)),
                        Text(_formatDuration(_duration),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
