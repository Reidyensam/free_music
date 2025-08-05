class Comentario {
  final String id;
  final String playlistId;
  final String autorId;
  final String texto;
  final DateTime fecha;
  final String? autorNombre; // 👈 campo opcional para mostrar nombre

  Comentario({
    required this.id,
    required this.playlistId,
    required this.autorId,
    required this.texto,
    required this.fecha,
    this.autorNombre,
  });

  factory Comentario.fromMap(Map<String, dynamic> map) => Comentario(
    id: map['id'],
    playlistId: map['playlist_id'],
    autorId: map['autor_id'],
    texto: map['texto'],
    fecha: DateTime.parse(map['fecha_creacion']),
    autorNombre: map['autor_nombre'],
  );
}