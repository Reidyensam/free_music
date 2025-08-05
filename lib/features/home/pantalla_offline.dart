import 'package:flutter/material.dart';

class PantallaOffline extends StatelessWidget {
  const PantallaOffline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Modo sin conexión activado',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tu música sigue contigo.\nExplora lo último que escuchaste y disfruta sin límites.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar a biblioteca local
                },
                icon: Icon(Icons.library_music),
                label: Text('Ir a mi biblioteca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Intentar reconectar o mostrar red info
                },
                icon: Icon(Icons.wifi),
                label: Text('Reintentar conexión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
