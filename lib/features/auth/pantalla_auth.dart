import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/proveedor_auth.dart';
import '../../providers/tema_provider.dart';
import '../../core/tema.dart';

class PantallaAuth extends ConsumerStatefulWidget {
  const PantallaAuth({super.key});

  @override
  ConsumerState<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends ConsumerState<PantallaAuth> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();

  bool esRegistro = false;
  String? error;

  // 🌈 Nuevo: valor inicial del tema visual
  String temaSeleccionado = 'Turquesa';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(temaProvider);
    final colorPrincipal = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('🎶 FreeMusic')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v!.isEmpty ? 'Escribe un correo' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (v) =>
                        v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  if (esRegistro) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                      validator: (v) =>
                          v!.isEmpty ? 'Pon tu nombre de usuario' : null,
                    ),
                    const SizedBox(height: 10),

                    // 🌈 Dropdown de selección de tema
                    DropdownButtonFormField<String>(
                      value: temaSeleccionado,
                      decoration: const InputDecoration(labelText: 'Tema visual'),
                      items: temasPorNombre.keys.map((nombre) {
                        return DropdownMenuItem(
                          value: nombre,
                          child: Text(nombre),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (valor != null) {
                          setState(() => temaSeleccionado = valor);
                          ref.read(temaProvider.notifier).state = temasPorNombre[valor]!;
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrincipal,
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final auth = ref.read(proveedorAuth);
                      try {
                        setState(() => error = null);
                        if (esRegistro) {
                          await auth.registrar(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                            username: usernameCtrl.text.trim(),
                            temaVisual: temaSeleccionado,
                          );
                        } else {
                          await auth.iniciarSesion(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                          );
                        }
                      } catch (e) {
                        setState(() => error = 'Error: ${e.toString()}');
                      }
                    },
                    child: Text(esRegistro ? 'Crear cuenta' : 'Iniciar sesión'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => esRegistro = !esRegistro),
                    child: Text(
                      esRegistro
                          ? '¿Ya tienes cuenta? Inicia sesión'
                          : '¿No tienes cuenta? Regístrate',
                      style: TextStyle(color: colorPrincipal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}