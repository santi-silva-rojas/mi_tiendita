import 'package:flutter/material.dart';

/// Vista para la gestión de cuentas por cobrar y clientes fiados.
class PantallaFiados extends StatelessWidget {
  const PantallaFiados({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '👥 Cuentas por Cobrar (Fiados)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}