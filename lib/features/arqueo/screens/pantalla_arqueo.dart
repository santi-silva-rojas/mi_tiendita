import 'package:flutter/material.dart';

/// Vista para el arqueo, cuadre de caja y cierres de turno.
class PantallaArqueo extends StatelessWidget {
  const PantallaArqueo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_sharp, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '💵 Arqueo y Cierre de Caja',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}