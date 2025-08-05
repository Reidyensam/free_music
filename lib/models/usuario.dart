class Usuario {
  final String id;
  final String correo;
  final String nombreUsuario;
  final String rol;
  final String temaVisual;
  final bool? modoOscuro; // 👈 NUEVO

  Usuario({
    required this.id,
    required this.correo,
    required this.nombreUsuario,
    required this.rol,
    required this.temaVisual,
    this.modoOscuro,
  });

  Usuario copyWith({
    String? id,
    String? correo,
    String? nombreUsuario,
    String? rol,
    String? temaVisual,
    bool? modoOscuro,
  }) {
    return Usuario(
      id: id ?? this.id,
      correo: correo ?? this.correo,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      rol: rol ?? this.rol,
      temaVisual: temaVisual ?? this.temaVisual,
      modoOscuro: modoOscuro ?? this.modoOscuro, 
    );
  }

  factory Usuario.desdeJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      correo: json['email'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      rol: json['rol'] ?? 'usuario',
      temaVisual: json['tema_visual'] ?? 'Turquesa',
      modoOscuro: json['modo_oscuro'] is bool ? json['modo_oscuro'] as bool : null,
    );
  }

  Map<String, dynamic> aJson() => {
        'id': id,
        'email': correo,
        'nombre_usuario': nombreUsuario,
        'rol': rol,
        'tema_visual': temaVisual,
        'modo_oscuro': modoOscuro,
      };
}