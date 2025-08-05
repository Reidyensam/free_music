import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/pantalla_home.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool cargando = false;
  String? error;

  Future<void> registrar() async {
    final nombre = nombreCtrl.text.trim();
    final telefono = telefonoCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if ([nombre, telefono, email, password].any((v) => v.isEmpty)) {
      setState(() => error = 'Todos los campos son obligatorios.');
      return;
    }

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = res.user?.id;
      final currentAuth = Supabase.instance.client.auth.currentUser?.id;

      print('🔐 UID registrado: $userId');
      print('📎 UID autenticado: $currentAuth');

      if (userId != null && currentAuth != null && userId == currentAuth) {
        final insertResponse = await Supabase.instance.client
            .from('usuarios')
            .insert({
          'id': userId,
          'nombre_usuario': nombre,
          'email': email,
          'telefono': telefono,
          'rol': 'usuario',
          'tema_visual': '#FF007A8A', // 🎨 color predeterminado
        });

        print('📥 Resultado insert: $insertResponse');
      } else {
        setState(() => error = 'Fallo de autenticación. Intentalo de nuevo.');
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaHome()),
      );
    } on AuthException catch (e) {
      final mensaje = e.message.toLowerCase();
      if (mensaje.contains('user already registered')) {
        setState(() => error =
            'Ese correo ya está registrado. ¿Querés iniciar sesión?');
      } else if (mensaje.contains('invalid email')) {
        setState(() => error = 'El correo no es válido.');
      } else if (mensaje.contains('password should be at least')) {
        setState(() =>
            error = 'La contraseña es demasiado corta (mínimo 6 caracteres).');
      } else {
        setState(() => error = 'Error de autenticación: ${e.message}');
      }
    } catch (e) {
      print('❌ Error inesperado: $e');
      setState(() => error = 'Ocurrió un error inesperado. Intentalo más tarde.');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    telefonoCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            const SizedBox(height: 8),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: registrar,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Registrarme'),
                  ),
          ],
        ),
      ),
    );
  }
}