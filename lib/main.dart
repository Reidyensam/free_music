import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'providers/tema_provider.dart';
import 'services/servicio_supabase.dart';
import 'features/auth/pantalla_login.dart';
import 'features/home/pantalla_home.dart';
import 'features/home/pantalla_offline.dart'; // ajustá la ruta si está en otra carpeta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    // Android config opcional
  }

  // ✅ Cargar variables .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}');
  } catch (e) {
    debugPrint('❌ Error cargando .env: $e');
  }

  // ✅ Inicializar Supabase
  await ServicioSupabase.iniciar();

  // ✅ Ejecutar App
  runApp(const ProviderScope(child: FreeMusicApp()));
}

class FreeMusicApp extends ConsumerStatefulWidget {
  const FreeMusicApp({super.key});

  @override
  ConsumerState<FreeMusicApp> createState() => _FreeMusicAppState();
}

class _FreeMusicAppState extends ConsumerState<FreeMusicApp> {
  bool cargando = true;
  bool logueado = false;
  bool conectado = true;

  @override
  void initState() {
    super.initState();
    verificarInicio();
  }

  Future<void> verificarInicio() async {
    final connectivity = Connectivity();
    final estadoRed = await connectivity.checkConnectivity();
    final tieneRed = estadoRed != ConnectivityResult.none;

    final session = Supabase.instance.client.auth.currentSession;

    setState(() {
      conectado = tieneRed;
      logueado = session != null;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = ref.watch(temaProvider);

    if (cargando) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: tema,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'FreeMusic',
      debugShowCheckedModeBanner: false,
      theme: tema,
      home: conectado
          ? (logueado ? const PantallaHome() : const PantallaLogin())
          : const PantallaOffline(),
    );
  }
}
