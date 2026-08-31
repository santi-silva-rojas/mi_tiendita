import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/providers/pos_provider.dart';
import 'core/providers/inventario_provider.dart';
import 'core/widgets/menu_lateral.dart';
import 'features/pos/screens/pantalla_pos.dart';
import 'features/dashboard/screens/pantalla_dashboard.dart';
import 'features/fiados/screens/pantalla_fiados.dart';
import 'features/inventario/screens/pantalla_inventario.dart';
import 'features/arqueo/screens/pantalla_arqueo.dart';
import 'features/configuracion/screens/pantalla_configuracion.dart';

void main() {
  // Inicialización del motor de SQLite para aplicaciones de Escritorio (Windows / Linux / macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
      ],
      child: const MiApp(),
    ),
  );
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

class ContenedorPrincipal extends StatefulWidget {
  const ContenedorPrincipal({super.key});

  @override
  State<ContenedorPrincipal> createState() => _ContenedorPrincipalState();
}

class _ContenedorPrincipalState extends State<ContenedorPrincipal> {
  int _indiceSeleccionado = 0;

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
          MenuLateral(
            indiceSeleccionado: _indiceSeleccionado,
            onOpcionSeleccionada: (nuevoIndice) {
              setState(() {
                _indiceSeleccionado = nuevoIndice;
              });
            },
          ),
          Expanded(
            child: _pantallas[_indiceSeleccionado],
          ),
        ],
      ),
    );
  }
}