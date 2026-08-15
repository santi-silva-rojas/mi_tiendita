import 'package:flutter/material.dart';

/// Vista principal del Punto de Venta (POS).
///
/// Contiene el catálogo de selección rápida a la izquierda
/// y la gestión de carrito, cantidades y proceso de cobro a la derecha.
class PantallaPOS extends StatefulWidget {
  const PantallaPOS({super.key});

  @override
  State<PantallaPOS> createState() => _PantallaPOSState();
}

class _PantallaPOSState extends State<PantallaPOS> {
  // Lista que almacena los productos añadidos a la venta actual
  final List<Map<String, dynamic>> _carrito = [];

  /// Agrega un producto al carrito o incrementa su cantidad si ya existe.
  void _agregarAlCarrito(String nombre, int precio) {
    setState(() {
      int index = _carrito.indexWhere((item) => item['nombre'] == nombre);

      if (index != -1) {
        _carrito[index]['cantidad'] += 1;
      } else {
        _carrito.add({'nombre': nombre, 'precio': precio, 'cantidad': 1});
      }
    });
  }

  /// Calcula el total a pagar recorriendo la lista de compras.
  int get _totalPagar {
    int total = 0;
    for (var item in _carrito) {
      total += (item['precio'] as int) * (item['cantidad'] as int);
    }
    return total;
  }

  /// Elimina un producto del carrito según su índice.
  void _eliminarDelCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  /// Vacía por completo la lista del carrito actual.
  void _vaciarCarrito() {
    setState(() {
      _carrito.clear();
    });
  }

  /// Incrementa en 1 la cantidad de un ítem del carrito.
  void _aumentarCantidad(int index) {
    setState(() {
      _carrito[index]['cantidad'] += 1;
    });
  }

  /// Disminuye en 1 la cantidad o elimina el producto si llega a cero.
  void _disminuirCantidad(int index) {
    setState(() {
      if (_carrito[index]['cantidad'] > 1) {
        _carrito[index]['cantidad'] -= 1;
      } else {
        _carrito.removeAt(index);
      }
    });
  }

  /// Despliega la ventana emergente para registrar el dinero recibido y dar la devuelta.
  void _mostrarVentanaCobro() {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ El carrito está vacío. Agrega productos antes de cobrar.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController pagoController = TextEditingController();
    int cambio = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextoDialogo) {
        return StatefulBuilder(
          builder: (contextoDialogoState, setStateModal) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.point_of_sale, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Finalizar Venta'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL: \$$_totalPagar',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pagoController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Efectivo recibido',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (valor) {
                      int recibido = int.tryParse(valor) ?? 0;
                      setStateModal(() {
                        cambio = recibido - _totalPagar;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Devuelta: \$${cambio < 0 ? 0 : cambio}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cambio < 0 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(contextoDialogo);
                  },
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: cambio < 0 || pagoController.text.isEmpty
                      ? null
                      : () {
                          Navigator.pop(contextoDialogo);
                          _vaciarCarrito();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ ¡Venta registrada con éxito!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                  child: const Text('CONFIRMAR PAGO'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ==========================================
        // PANEL IZQUIERDO: Catálogo y Búsqueda
        // ==========================================
        Container(
          width: 350,
          color: Colors.blue.shade50,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catálogo de Productos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar o escanear código...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Categorías Rápidas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton(
                    onPressed: () => _agregarAlCarrito('Pan Aliñado', 2000),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('🍞 Pan Aliñado\n2.000'),
                  ),
                  ElevatedButton(
                    onPressed: () => _agregarAlCarrito('Huevo AA', 600),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('🥚 Huevo AA\n600'),
                  ),
                  ElevatedButton(
                    onPressed: () => _agregarAlCarrito('Gaseosa 1.5L', 5000),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('🥤 Gaseosa 1.5L\n5.000'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ==========================================
        // PANEL DERECHO: Carrito de Compras
        // ==========================================
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado del Carrito
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🛒 Carrito de Compras',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _vaciarCarrito,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      tooltip: 'Vaciar Carrito',
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Lista de Productos Agregados
                Expanded(
                  child: _carrito.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay productos en la venta actual',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _carrito.length,
                          itemBuilder: (context, index) {
                            final producto = _carrito[index];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                producto['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '\$${producto['precio']} x ${producto['cantidad']}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => _disminuirCantidad(index),
                                  ),
                                  Text(
                                    '${producto['cantidad']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => _aumentarCantidad(index),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${producto['precio'] * producto['cantidad']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _eliminarDelCarrito(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 30),

                // Resumen de Total y Botón de Cobro
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL A PAGAR',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '\$ $_totalPagar',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _mostrarVentanaCobro,
                        icon: const Icon(Icons.payments),
                        label: const Text(
                          'COBRAR (F5)',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}