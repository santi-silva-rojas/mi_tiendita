import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/producto.dart';
import '../../../core/providers/inventario_provider.dart';

class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key});

  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  late TextEditingController _busquedaController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador del buscador con el valor del Provider
    final invProvider = Provider.of<InventarioProvider>(context, listen: false);
    _busquedaController = TextEditingController(
      text: invProvider.busquedaTexto,
    );
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  /// Despliega el formulario modal para Crear o Editar un producto
  void _mostrarModalProducto(
    BuildContext context, [
    Producto? productoExistente,
  ]) {
    final bool esEdicion = productoExistente != null;

    final codigoController = TextEditingController(
      text: esEdicion ? productoExistente.codigoBarras : '',
    );
    final nombreController = TextEditingController(
      text: esEdicion ? productoExistente.nombre : '',
    );
    final costoController = TextEditingController(
      text: esEdicion ? productoExistente.precioCosto.toString() : '',
    );
    final ventaController = TextEditingController(
      text: esEdicion ? productoExistente.precioVenta.toString() : '',
    );
    final stockController = TextEditingController(
      text: esEdicion ? productoExistente.stock.toString() : '',
    );

    String categoriaSeleccionada = esEdicion
        ? productoExistente.categoria
        : 'Panadería';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: Text(
            esEdicion ? '✏️ Editar Producto' : '📦 Nuevo Producto',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Barras / ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'Panadería',
                              'Abarrotes',
                              'Bebidas',
                              'Lácteos',
                              'Mecatos',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) categoriaSeleccionada = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: costoController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio Costo (\$)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ventaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio Venta (\$)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock Inicial / Existencias',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final provider = Provider.of<InventarioProvider>(
                  context,
                  listen: false,
                );

                final nuevo = Producto(
                  id: esEdicion
                      ? productoExistente.id
                      : DateTime.now().toString(),
                  codigoBarras: codigoController.text,
                  nombre: nombreController.text,
                  categoria: categoriaSeleccionada,
                  precioCosto: int.tryParse(costoController.text) ?? 0,
                  precioVenta: int.tryParse(ventaController.text) ?? 0,
                  stock: int.tryParse(stockController.text) ?? 0,
                );

                if (esEdicion) {
                  provider.editarProducto(productoExistente.id, nuevo);
                } else {
                  provider.agregarProducto(nuevo);
                }

                Navigator.pop(contextoDialogo);
              },
              child: Text(esEdicion ? 'Guardar Cambios' : 'Crear Producto'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventarioProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // ENCABEZADO Y BOTÓN ACCIÓN PRINCIPAL
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📦 Gestión de Inventario',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administra tu catálogo de productos, precios y existencias',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _mostrarModalProducto(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ==========================================
            // BARRA DE BÚSQUEDA Y CHIPS DE FILTRO
            // ==========================================
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Buscador
                    TextField(
                      controller: _busquedaController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o código de barras...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _busquedaController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _busquedaController.clear();
                                  invProvider.setBusquedaTexto('');
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (texto) {
                        invProvider.setBusquedaTexto(texto);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Chips de Categoría
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: invProvider.categoriasDisponibles.map((
                          categoria,
                        ) {
                          final esSeleccionado =
                              invProvider.categoriaSeleccionada == categoria;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(categoria),
                              selected: esSeleccionado,
                              selectedColor: Colors.blue.shade100,
                              labelStyle: TextStyle(
                                color: esSeleccionado
                                    ? Colors.blue.shade900
                                    : Colors.black87,
                                fontWeight: esSeleccionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (bool selected) {
                                if (selected) {
                                  invProvider.setCategoriaSeleccionada(
                                    categoria,
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==========================================
            // TABLA DE PRODUCTOS
            // ==========================================
            Expanded(
              child: Card(
                elevation: 2,
                child: invProvider.productosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron productos con ese filtro.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.blue.shade50,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Código / ID',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nombre',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Categoría',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Costo',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Venta',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Stock',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Acciones',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: invProvider.productosFiltrados.map((
                              producto,
                            ) {
                              final stockBajo = producto.stock <= 10;

                              return DataRow(
                                cells: [
                                  DataCell(Text(producto.codigoBarras)),
                                  DataCell(
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        producto.categoria,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  ),
                                  DataCell(Text('\$${producto.precioCosto}')),
                                  DataCell(
                                    Text(
                                      '\$${producto.precioVenta}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${producto.stock} unids',
                                      style: TextStyle(
                                        color: stockBajo
                                            ? Colors.red
                                            : Colors.black,
                                        fontWeight: stockBajo
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          tooltip: 'Editar',
                                          onPressed: () =>
                                              _mostrarModalProducto(
                                                context,
                                                producto,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Eliminar',
                                          onPressed: () {
                                            invProvider.eliminarProducto(
                                              producto.id,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
