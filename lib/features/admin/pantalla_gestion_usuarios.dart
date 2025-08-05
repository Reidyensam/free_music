import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/usuario_provider.dart';
import '../../services/servicio_supabase.dart';
import '../../models/usuario.dart';

class PantallaGestionUsuarios extends ConsumerStatefulWidget {
  const PantallaGestionUsuarios({super.key});

  @override
  ConsumerState<PantallaGestionUsuarios> createState() =>
      _PantallaGestionUsuariosState();
}

class _PantallaGestionUsuariosState
    extends ConsumerState<PantallaGestionUsuarios> {
  List<Usuario> listaUsuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
  setState(() => cargando = true);

  try {
    final respuesta = await ServicioSupabase.cliente
        .from('usuarios')
        .select('id, email, nombre_usuario, rol, tema_visual, modo_oscuro')
        .order('nombre_usuario');

    print('📦 Respuesta cruda Supabase: $respuesta');

    final mapeados = <Usuario>[];
    for (final entrada in respuesta) {
      try {
        final user = Usuario.desdeJson(entrada);
        print('🪪 ${user.id} – ${user.nombreUsuario} – ${user.rol}');
        mapeados.add(user);
      } catch (e) {
        print('❌ Error mapeando usuario: $entrada\n💥 $e');
      }
    }

    print(
        '👥 Usuarios mapeados: ${mapeados.map((u) => u.nombreUsuario).join(', ')}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Usuarios cargados: ${mapeados.length}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      listaUsuarios = mapeados;
      cargando = false;
    });
  } catch (e) {
    print('❌ Error al cargar usuarios: $e');
    setState(() => cargando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al obtener usuarios: $e')),
    );
  }
}

  Future<void> _actualizarRol(String idUsuario, String nuevoRol) async {
    try {
      await ServicioSupabase.cliente
          .from('usuarios')
          .update({'rol': nuevoRol}).eq('id', idUsuario);

      final usuario = listaUsuarios.firstWhere(
        (u) => u.id == idUsuario,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoRol == 'admin'
                ? '👑 ${usuario.nombreUsuario} Promovido a Admin'
                : '🚫 ${usuario.nombreUsuario} Degradado a Usuario',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      await _cargarUsuarios();
    } catch (e) {
      print('❌ Error al actualizar rol: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar rol: $e')),
      );
    }
  }

  Future<void> _verificarCoincidenciaUID() async {
    final usuarioActual = ref.read(usuarioProvider);
    print('🧾 ID local desde Provider: ${usuarioActual?.id}');

    final result = await ServicioSupabase.cliente.auth.getUser();
    print('🔐 Auth UID de sesión: ${result.user?.id}');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuarioActual?.id == result.user?.id
                ? '✅ ID y UID coinciden'
                : '⚠️ ID y UID NO coinciden',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioActual = ref.watch(usuarioProvider);

    if (usuarioActual?.rol != 'admin') {
      return const Scaffold(
        body: Center(child: Text('🚫 Acceso restringido a administradores')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Gestión de Usuarios'),
        actions: [
          IconButton(
            tooltip: 'Verificar UID',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: _verificarCoincidenciaUID,
          )
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarUsuarios,
              child: ListView.separated(
                itemCount: listaUsuarios.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final usuario = listaUsuarios[index];
                  final esAdmin = usuario.rol == 'admin';
                  final esElMismo = usuario.id == usuarioActual?.id;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                          usuario.nombreUsuario.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(usuario.nombreUsuario),
                    subtitle: Text(usuario.correo),
                    trailing: esElMismo
                        ? const Text('Tú', style: TextStyle(color: Colors.grey))
                        : ElevatedButton.icon(
                            icon: Icon(esAdmin
                                ? Icons.remove_moderator_outlined
                                : Icons.security_outlined),
                            label:
                                Text(esAdmin ? 'Quitar Admin' : 'Hacer Admin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: esAdmin
                                  ? Colors.red.shade300
                                  : Colors.green.shade400,
                            ),
                            onPressed: () => _confirmarCambio(
                              usuario,
                              esAdmin ? 'usuario' : 'admin',
                            ),
                          ),
                  );
                },
              ),
            ),
    );
  }

  void _confirmarCambio(Usuario usuario, String nuevoRol) {
    final esPromocion = nuevoRol == 'admin';
    final accion =
        esPromocion ? 'promover a admin' : 'quitar derechos de admin';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¿Confirmás cambiar el rol?'),
        content: Text('Vas a $accion a ${usuario.nombreUsuario}. ¿Seguro?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Confirmar'),
            onPressed: () async {
              Navigator.pop(context);
              await _actualizarRol(usuario.id, nuevoRol);
            },
          ),
        ],
      ),
    );
  }
}
