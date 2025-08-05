import 'package:flutter/services.dart';

Future<void> obtenerAudioDeYoutube(String videoId) async {
  const plataforma = MethodChannel('newpipe');

  try {
    final data = await plataforma.invokeMethod('getStreamData', {
      'videoId': videoId,
    });

    final titulo = data['title'];
    final audioUrl = data['audioUrl'];
    print('✅ Audio de "$titulo" → $audioUrl');

    // Continuamos con la descarga en el siguiente paso
  } catch (e) {
    print('❌ Error al obtener audio: $e');
  }
}