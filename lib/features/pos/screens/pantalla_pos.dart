import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/pos_provider.dart';
import '../../../core/providers/inventario_provider.dart';

/// Vista principal del Punto de Venta (POS) utilizando Provider para gestión de estado.
class PantallaPOS extends StatefulWidget {
  const PantallaPOS({super.key});

  /// Despliega la ventana emergente para registrar el dinero recibido y dar la devuelta.
  @override
  State<PantallaPOS> createState() => _PantallaPOSState();
}

class _PantallaPOSState extends State<PantallaPOS> {
  // Variable local para que la búsqueda solo afecte al POS
  String _busquedaPOS = '';

  void _mostrarVentanaCobro(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context, listen: false);
    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );

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
                  onPressed: () => Navigator.pop(contextoDialogo),
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
                          for (var item in posProvider.carrito) {
                            inventarioProvider.descontarStock(
                              item.idProducto,
                              item.cantidad,
                            );
                          }

                          posProvider.vaciarCarrito();
                          Navigator.pop(contextoDialogo);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ ¡Venta registrada y stock actualizado!',
                              ),
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
    final inventarioProvider = Provider.of<InventarioProvider>(context);

    // 1. Obtenemos TODOS los productos sin usar los filtros globales de la pantalla de inventario
    final todosLosProductos = inventarioProvider.todosLosProductos;

    // 2. Filtramos ÚNICAMENTE según lo que el cajero escribe en el buscador del POS
    final productosFiltradosPOS = todosLosProductos.where((p) {
      final texto = _busquedaPOS.toLowerCase();
      return p.nombre.toLowerCase().contains(texto) ||
          p.codigoBarras.contains(texto);
    }).toList();

    return Row(
      children: [
        // ==========================================
        // PANEL IZQUIERDO: Catálogo Dinámico Local
        // ==========================================
        Container(
          width: 380,
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

              // Buscador INDEPENDIENTE del POS
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o código...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (valor) {
                  // Actualizamos solo el estado de esta pantalla
                  setState(() {
                    _busquedaPOS = valor;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Grilla filtrada dinámicamente según _busquedaPOS
              Expanded(
                child: productosFiltradosPOS.isEmpty
                    ? Center(
                        child: todosLosProductos.isEmpty
                            ? const Text('No hay productos cargados')
                            : const Text(
                                'No se encontraron resultados para la búsqueda',
                              ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: productosFiltradosPOS.length,
                        itemBuilder: (context, index) {
                          final prod = productosFiltradosPOS[index];
                          final sinStock = prod.stock <= 0;

                          return InkWell(
                            onTap: sinStock
                                ? null
                                : () {
                                    bool agregado = posProvider.agregarProducto(
                                      prod,
                                    );
                                    if (!agregado) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '⚠️ Alcanzaste el límite de stock disponible de ${prod.nombre}',
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                            child: Card(
                              color: sinStock
                                  ? Colors.grey.shade300
                                  : Colors.white,
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      prod.nombre,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: sinStock
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${prod.precioVenta}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sinStock
                                          ? '¡Agotado!'
                                          : 'Stock: ${prod.stock}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: sinStock
                                            ? Colors.red
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
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
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: posProvider.carrito.length,
                          itemBuilder: (context, index) {
                            final item = posProvider.carrito[index];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                item.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '\$${item.precio} x ${item.cantidad}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () =>
                                        posProvider.disminuirCantidad(index),
                                  ),
                                  Text(
                                    '${item.cantidad}',
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
                                    onPressed: () {
                                      bool pudo = posProvider.aumentarCantidad(
                                        index,
                                      );
                                      if (!pudo) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '⚠️ No hay más stock disponible.',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${item.subtotal}',
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
                                    onPressed: () =>
                                        posProvider.eliminarProducto(index),
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
