import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/pos_provider.dart';
import '../../../core/providers/inventario_provider.dart';
import '../../../core/providers/clientes_provider.dart';

class PantallaPOS extends StatefulWidget {
  const PantallaPOS({super.key});

  @override
  State<PantallaPOS> createState() => _PantallaPOSState();
}

class _PantallaPOSState extends State<PantallaPOS> {
  String _busquedaPOS = '';

  void _mostrarVentanaCobro(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context, listen: false);
    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );
    final clientesProvider = Provider.of<ClientesProvider>(
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
    String metodoPago = 'EFECTIVO';
    String? clienteSeleccionadoId;

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
              content: SizedBox(
                width: 400, // Ancho definido para evitar desbordamientos
                child: SingleChildScrollView(
                  child: Column(
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
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ChoiceChip(
                            label: const Text('💵 Efectivo'),
                            selected: metodoPago == 'EFECTIVO',
                            onSelected: (val) {
                              if (val)
                                setStateModal(() => metodoPago = 'EFECTIVO');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('📋 Fiado / Crédito'),
                            selected: metodoPago == 'FIADO',
                            onSelected: (val) {
                              if (val)
                                setStateModal(() => metodoPago = 'FIADO');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (metodoPago == 'EFECTIVO') ...[
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
                        const SizedBox(height: 15),
                        Text(
                          'Devuelta: \$${cambio < 0 ? 0 : cambio}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cambio < 0 ? Colors.red : Colors.blue,
                          ),
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          value: clienteSeleccionadoId,
                          hint: const Text('Seleccionar Cliente'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: clientesProvider.clientes.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                '${c.nombre} (Deuda: \$${c.saldoDeuda})',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setStateModal(() => clienteSeleccionadoId = val);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
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
                  onPressed:
                      (metodoPago == 'EFECTIVO' &&
                              (cambio < 0 || pagoController.text.isEmpty)) ||
                          (metodoPago == 'FIADO' &&
                              clienteSeleccionadoId == null)
                      ? null
                      : () async {
                          if (metodoPago == 'FIADO') {
                            bool exito = await clientesProvider.registrarFiado(
                              clienteSeleccionadoId!,
                              posProvider.totalPagar,
                            );

                            if (!exito) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '❌ La compra supera el límite de crédito del cliente.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }
                          }

                          for (var item in posProvider.carrito) {
                            inventarioProvider.descontarStock(
                              item.idProducto,
                              item.cantidad,
                            );
                          }

                          posProvider.vaciarCarrito();
                          if (context.mounted) Navigator.pop(contextoDialogo);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                metodoPago == 'EFECTIVO'
                                    ? '✅ ¡Venta registrada con éxito!'
                                    : '📋 ¡Compra a crédito registrada correctamente!',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
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
    final posProvider = Provider.of<PosProvider>(context);
    final inventarioProvider = Provider.of<InventarioProvider>(context);
    final todosLosProductos = inventarioProvider.todosLosProductos;

    final productosFiltradosPOS = todosLosProductos.where((p) {
      final texto = _busquedaPOS.toLowerCase();
      return p.nombre.toLowerCase().contains(texto) ||
          p.codigoBarras.contains(texto);
    }).toList();

    return Row(
      children: [
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
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o código...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (valor) {
                  setState(() {
                    _busquedaPOS = valor;
                  });
                },
              ),
              const SizedBox(height: 16),
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
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
