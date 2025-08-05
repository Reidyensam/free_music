import 'package:flutter/material.dart';

class PantallaSinConexion extends StatelessWidget {
  const PantallaSinConexion({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '🚫 Sin conexión a internet',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}