import 'package:flutter/material.dart';

/// Componente de menú lateral reutilizable para la navegación del POS.
class MenuLateral extends StatelessWidget {
  final int indiceSeleccionado;
  final Function(int) onOpcionSeleccionada;

  const MenuLateral({
    super.key,
    required this.indiceSeleccionado,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.blueGrey.shade900,
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                '⚡ POS SYSTEM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildItemMenu(0, Icons.point_of_sale, 'Ventas (POS)'),
          _buildItemMenu(1, Icons.dashboard, 'Historial'),
          _buildItemMenu(2, Icons.people, 'Fiados'),
          _buildItemMenu(3, Icons.inventory, 'Inventario'),
          _buildItemMenu(4, Icons.point_of_sale_sharp, 'Arqueo Caja'),
          _buildItemMenu(5, Icons.settings, 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildItemMenu(int index, IconData icono, String titulo) {
    final bool estaSeleccionado = index == indiceSeleccionado;

    return ListTile(
      leading: Icon(icono, color: estaSeleccionado ? Colors.greenAccent : Colors.white70),
      title: Text(
        titulo,
        style: TextStyle(
          color: estaSeleccionado ? Colors.greenAccent : Colors.white,
          fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: estaSeleccionado,
      selectedTileColor: Colors.white10,
      onTap: () => onOpcionSeleccionada(index),
    );
  }
}