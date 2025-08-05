class Reaccion {
  final String id;
  final String emoji;
  final String playlistId;
  final String usuarioId;
  final DateTime fecha;

  Reaccion({
    required this.id,
    required this.emoji,
    required this.playlistId,
    required this.usuarioId,
    required this.fecha,
  });

  factory Reaccion.fromMap(Map<String, dynamic> map) => Reaccion(
    id: map['id'],
    emoji: map['emocion_sentida'],
    playlistId: map['playlist_id'],
    usuarioId: map['usuario_id'],
    fecha: DateTime.parse(map['fecha']),
  );
}