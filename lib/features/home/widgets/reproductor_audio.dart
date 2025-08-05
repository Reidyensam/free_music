import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


class ReproductorAudio extends StatefulWidget {
  final String url;
  final String titulo;

  const ReproductorAudio({super.key, required this.url, required this.titulo});

  @override
  State<ReproductorAudio> createState() => _ReproductorAudioState();
}

class _ReproductorAudioState extends State<ReproductorAudio> {
  late AudioPlayer player;
  bool reproduciendo = false;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setUrl(widget.url);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void togglePlay() async {
    if (reproduciendo) {
      await player.pause();
    } else {
      await player.play();
    }
    setState(() => reproduciendo = !reproduciendo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.titulo, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            IconButton(
              icon: Icon(reproduciendo ? Icons.pause : Icons.play_arrow),
              onPressed: togglePlay,
            ),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final dur = player.duration ?? Duration.zero;
                  return Slider(
                    value: pos.inSeconds.toDouble(),
                    max: dur.inSeconds.toDouble(),
                    onChanged: (val) => player.seek(Duration(seconds: val.toInt())),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}