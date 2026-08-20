import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/pos_provider.dart';

/// Vista principal del Punto de Venta (POS) utilizando Provider para gestión de estado.
class PantallaPOS extends StatelessWidget {
  const PantallaPOS({super.key});

  /// Despliega la ventana emergente para registrar el dinero recibido y dar la devuelta.
  void _mostrarVentanaCobro(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context, listen: false);

    if (posProvider.carrito.isEmpty) {
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
                    'TOTAL: \$${posProvider.totalPagar}',
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
                        cambio = recibido - posProvider.totalPagar;
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
                          posProvider.vaciarCarrito();

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
    // Escuchamos los cambios en el estado del POS
    final posProvider = Provider.of<PosProvider>(context);

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
                    onPressed: () => posProvider.agregarProducto('Pan Aliñado', 2000),
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
                    onPressed: () => posProvider.agregarProducto('Huevo AA', 600),
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
                    onPressed: () => posProvider.agregarProducto('Gaseosa 1.5L', 5000),
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
                    Text(
                      '🛒 Carrito de Compras (${posProvider.cantidadTotalArticulos})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: posProvider.vaciarCarrito,
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
                  child: posProvider.carrito.isEmpty
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
                          itemCount: posProvider.carrito.length,
                          itemBuilder: (context, index) {
                            final producto = posProvider.carrito[index];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                producto.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '\$${producto.precio} x ${producto.cantidad}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => posProvider.disminuirCantidad(index),
                                  ),
                                  Text(
                                    '${producto.cantidad}',
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
                                    onPressed: () => posProvider.aumentarCantidad(index),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${producto.subtotal}',
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
                                    onPressed: () => posProvider.eliminarProducto(index),
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
                            '\$ ${posProvider.totalPagar}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarVentanaCobro(context),
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