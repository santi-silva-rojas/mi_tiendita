import 'package:flutter/material.dart';

/// Vista para la administración de catálogo, stock y precios.
class PantallaInventario extends StatelessWidget {
  const PantallaInventario({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '📦 Gestor de Inventario y Productos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}