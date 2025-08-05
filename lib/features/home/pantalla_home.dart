import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_music/features/auth/pantalla_perfil.dart';
import '../../models/usuario.dart';
import '../../providers/proveedor_auth.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/tema_provider.dart';
import '../../core/tema.dart';
import '../auth/pantalla_login.dart';
import '../admin/pantalla_gestion_usuarios.dart';
import '../playlists/pantalla_crear_playlist.dart';
import '../playlists/pantalla_mis_playlists.dart';
import 'widgets/lista_playlists.dart';

class PantallaHome extends ConsumerStatefulWidget {
  const PantallaHome({super.key});

  @override
  ConsumerState<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends ConsumerState<PantallaHome> {
  Usuario? perfil;
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarPerfilYAplicarTema();
  }

  Future<void> _cargarPerfilYAplicarTema() async {
    try {
      final auth = ref.read(proveedorAuth);
      final datos = await auth.obtenerPerfil();

      if (datos == null) {
        setState(() {
          error = 'Debes iniciar sesión';
          cargando = false;
        });
        return;
      }

      final usuarioActual = ref.read(usuarioProvider);

      if (usuarioActual == null || usuarioActual.id != datos.id) {
        ref.read(usuarioProvider.notifier).state = datos;

        final clave = datos.temaVisual;
        final tema = temasPorNombre[clave] ?? temasPorNombre['Turquesa']!;
        ref.read(temaProvider.notifier).state = tema;

        print('🎨 Tema aplicado: $clave');
      }

      setState(() {
        perfil = datos;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ocurrió un error: $e';
        cargando = false;
      });
    }
  }

  void refrescarPlaylists() {
    ref.invalidate(playlistsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    final perfilUsuario = perfil!;
    final esAdmin = perfilUsuario.rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeMusic 🎧'),
        actions: [
          if (esAdmin)
            InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaGestionUsuarios(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'Cambiar tema',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaPerfil()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final auth = ref.read(proveedorAuth);
              await auth.cerrarSesion();
              ref.invalidate(usuarioProvider);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PantallaLogin()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${perfilUsuario.nombreUsuario} 👋',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Rol: ${perfilUsuario.rol}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Text('Playlists Públicas', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              const Expanded(child: ListaPlaylists()),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PantallaMisPlaylists(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.library_music_outlined),
                    label: const Text('Mis Playlists'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PantallaCrearPlaylist(),
                        ),
                      );
                      if (resultado == true) {
                        refrescarPlaylists();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva Playlist'),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}