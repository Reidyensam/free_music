import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/pantalla_home.dart';
import 'pantalla_registro.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool cargando = false;
  String? errorMensaje;

  Future<void> iniciarSesion() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMensaje = 'Por favor, completá todos los campos';
      });
      return;
    }

    setState(() {
      cargando = true;
      errorMensaje = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaHome()),
      );
    } on AuthException catch (e) {
      setState(() => errorMensaje = e.message);
    } catch (_) {
      setState(() => errorMensaje = 'Error inesperado.');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 16),
            if (errorMensaje != null)
              Text(errorMensaje!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: iniciarSesion,
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaRegistro()),
                );
              },
              child: const Text('¿No tienes cuenta? Registrate'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
