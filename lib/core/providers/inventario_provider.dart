import 'package:flutter/material.dart';
import '../models/producto.dart';

class InventarioProvider extends ChangeNotifier {
  // Lista principal de productos
  final List<Producto> _productos = [
    Producto(
      id: '1',
      codigoBarras: '770123456781',
      nombre: 'Pan Aliñado Grandes',
      categoria: 'Panadería',
      precioCosto: 1200,
      precioVenta: 2000,
      stock: 25,
    ),
    Producto(
      id: '2',
      codigoBarras: '770123456782',
      nombre: 'Huevo AA x30',
      categoria: 'Abarrotes',
      precioCosto: 14000,
      precioVenta: 18000,
      stock: 10,
    ),
    Producto(
      id: '3',
      codigoBarras: '770123456783',
      nombre: 'Gaseosa 1.5L Coca-Cola',
      categoria: 'Bebidas',
      precioCosto: 3800,
      precioVenta: 5000,
      stock: 18,
    ),
    Producto(
      id: '4',
      codigoBarras: '770123456784',
      nombre: 'Pan tajado Bimbo',
      categoria: 'Panadería',
      precioCosto: 4500,
      precioVenta: 6200,
      stock: 8,
    ),
    Producto(
      id: '5',
      codigoBarras: '770123456785',
      nombre: 'Leche Alquería 1L',
      categoria: 'Lácteos',
      precioCosto: 3200,
      precioVenta: 4200,
      stock: 30,
    ),
  ];

  // Filtros activos
  String _busquedaTexto = '';
  String _categoriaSeleccionada = 'Todos';

  // Categorías disponibles para los chips
  final List<String> categoriasDisponibles = [
    'Todos',
    'Panadería',
    'Abarrotes',
    'Bebidas',
    'Lácteos',
    'Mecatos',
  ];

  // Getters para exponer datos a la vista
  String get busquedaTexto => _busquedaTexto;
  String get categoriaSeleccionada => _categoriaSeleccionada;

  /// Retorna la lista de productos filtrada dinámicamente por Texto y Categoría.
  List<Producto> get productosFiltrados {
    return _productos.where((producto) {
      // 1. Filtrar por texto (coincide con nombre o código)
      final coincideTexto =
          producto.nombre.toLowerCase().contains(
            _busquedaTexto.toLowerCase(),
          ) ||
          producto.codigoBarras.contains(_busquedaTexto);

      // 2. Filtrar por chip de categoría
      final coincideCategoria =
          _categoriaSeleccionada == 'Todos' ||
          producto.categoria == _categoriaSeleccionada;

      return coincideTexto && coincideCategoria;
    }).toList();
  }

  /// Actualiza el texto de búsqueda sin borrar lo que el usuario escribió.
  void setBusquedaTexto(String texto) {
    _busquedaTexto = texto;
    notifyListeners();
  }

  /// Cambia el chip de categoría seleccionado.
  void setCategoriaSeleccionada(String categoria) {
    _categoriaSeleccionada = categoria;
    notifyListeners();
  }

  /// Agrega un nuevo producto.
  void agregarProducto(Producto nuevoProducto) {
    _productos.add(nuevoProducto);
    notifyListeners();
  }

  /// Edita un producto existente por ID.
  void editarProducto(String id, Producto productoActualizado) {
    final index = _productos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _productos[index] = productoActualizado;
      notifyListeners();
    }
  }

  /// Elimina un producto.
  void eliminarProducto(String id) {
    _productos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ==========================================
  // MÉTODOS PARA CONEXIÓN CON EL POS
  // ==========================================

  /// Descuenta la cantidad vendida del stock de un producto
  void descontarStock(String idProducto, int cantidadVendida) {
    final index = _productos.indexWhere((p) => p.id == idProducto);
    if (index != -1) {
      final actual = _productos[index];
      final nuevoStock = (actual.stock - cantidadVendida).clamp(
        0,
        actual.stock,
      );

      _productos[index] = Producto(
        id: actual.id,
        codigoBarras: actual.codigoBarras,
        nombre: actual.nombre,
        categoria: actual.categoria,
        precioCosto: actual.precioCosto,
        precioVenta: actual.precioVenta,
        stock: nuevoStock,
      );
      notifyListeners();
    }
  }

  /// Retorna un producto por su ID
  Producto? obtenerPorId(String id) {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retorna TODOS los productos sin aplicar los filtros globales del inventario
  List<Producto> get todosLosProductos => List.unmodifiable(_productos);
}
