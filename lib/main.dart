import 'package:flutter/material.dart';
import 'core/widgets/menu_lateral.dart';
import 'features/pos/screens/pantalla_pos.dart';
import 'features/dashboard/screens/pantalla_dashboard.dart';
import 'features/fiados/screens/pantalla_fiados.dart';
import 'features/inventario/screens/pantalla_inventario.dart';
import 'features/arqueo/screens/pantalla_arqueo.dart';
import 'features/configuracion/screens/pantalla_configuracion.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema POS',
      home: ContenedorPrincipal(),
    );
  }
}

/// Pantalla principal que sostiene el menú lateral y la vista activa.
class ContenedorPrincipal extends StatefulWidget {
  const ContenedorPrincipal({super.key});

  @override
  State<ContenedorPrincipal> createState() => _ContenedorPrincipalState();
}

class _ContenedorPrincipalState extends State<ContenedorPrincipal> {
  // Índice para saber qué pantalla mostrar (0: Ventas, 1: Historial, etc.)
  int _indiceSeleccionado = 0;

  // Lista con las 6 vistas principales de la aplicación
  final List<Widget> _pantallas = const [
    PantallaPOS(),
    PantallaDashboard(),
    PantallaFiados(),
    PantallaInventario(),
    PantallaArqueo(),
    PantallaConfiguracion(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menú Lateral Fijo a la izquierda
          MenuLateral(
            indiceSeleccionado: _indiceSeleccionado,
            onOpcionSeleccionada: (nuevoIndice) {
              setState(() {
                _indiceSeleccionado = nuevoIndice;
              });
            },
          ),
          // Vista Central Cambiante
          Expanded(
            child: _pantallas[_indiceSeleccionado],
          ),
        ],
      ),
    );
  }
}