import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

class DailymotionAudioPlayer extends StatefulWidget {
  final String videoUrl;

  const DailymotionAudioPlayer({super.key, required this.videoUrl});

  @override
  State<DailymotionAudioPlayer> createState() => _DailymotionAudioPlayerState();
}

class _DailymotionAudioPlayerState extends State<DailymotionAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  String? _mp3Url;
  bool _loading = false;
  String? _error;

  Future<void> fetchAndPlay() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Extraer el ID del video desde la URL
      final uri = Uri.parse(widget.videoUrl);
      final videoId = uri.pathSegments.last;

      // Simular un MP3 según el ID
      final fakeMp3Url = getFakeMp3Url(videoId);

      setState(() => _mp3Url = fakeMp3Url);
      await _player.setUrl(fakeMp3Url);
      _player.play();
    } catch (e) {
      setState(() => _error = '❌ Error al simular reproducción: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.music_note),
          label: const Text('Reproducir en audio'),
          onPressed: _loading ? null : fetchAndPlay,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        if (_mp3Url != null)
          TextButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Descargar MP3'),
            onPressed: () => launchUrl(Uri.parse(_mp3Url!)),
          ),
      ],
    );
  }
}

// 🔁 Simulación de enlaces MP3 según el ID del video
String getFakeMp3Url(String videoId) {
  switch (videoId) {
    case 'x8z1abc':
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    case 'x8z1def':
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
    case 'x8z1ghi':
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3';
    default:
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3';
  }
}

// 🔘 Botón compacto para usar en filas
Widget reproducirAudioButton({
  required String videoId,
  required BuildContext context,
}) {
  return TextButton.icon(
    icon: const Icon(Icons.music_note),
    label: const Text('Reproducir en audio'),
    onPressed: () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reproduciendo audio'),
          content: DailymotionAudioPlayer(
            videoUrl: 'https://www.dailymotion.com/video/$videoId',
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
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: const TextStyle(fontSize: 14),
    ),
  );
}