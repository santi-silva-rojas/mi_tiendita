import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../database/db_helper.dart';

class InventarioProvider extends ChangeNotifier {
  List<Producto> _productos = [];
  final DBHelper _dbHelper = DBHelper();

  String _busquedaTexto = '';
  String _categoriaSeleccionada = 'Todos';

  final List<String> categoriasDisponibles = [
    'Todos',
    'Panadería',
    'Abarrotes',
    'Bebidas',
    'Lácteos',
    'Mecatos',
  ];

  InventarioProvider() {
    cargarProductosDesdeDB();
  }

  String get busquedaTexto => _busquedaTexto;
  String get categoriaSeleccionada => _categoriaSeleccionada;

  /// Carga los productos guardados desde SQLite a la memoria local.
  Future<void> cargarProductosDesdeDB() async {
    List<Producto> dbProductos = await _dbHelper.obtenerProductos();

    // Semilla inicial si la base de datos está completamente vacía
    if (dbProductos.isEmpty) {
      final iniciales = [
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

      for (var p in iniciales) {
        await _dbHelper.insertarProducto(p);
      }
      dbProductos = await _dbHelper.obtenerProductos();
    }

    _productos = dbProductos;
    notifyListeners();
  }

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

  /// Agrega un nuevo producto en la base de datos y localmente.
  Future<void> agregarProducto(Producto nuevoProducto) async {
    await _dbHelper.insertarProducto(nuevoProducto);
    _productos.add(nuevoProducto);
    notifyListeners();
  }

  /// Edita un producto en SQLite y actualiza la lista.
  Future<void> editarProducto(String id, Producto productoActualizado) async {
    final index = _productos.indexWhere((p) => p.id == id);
    if (index != -1) {
      await _dbHelper.actualizarProducto(productoActualizado);
      _productos[index] = productoActualizado;
      notifyListeners();
    }
  }

  /// Elimina un producto de SQLite y de la lista.
  Future<void> eliminarProducto(String id) async {
    await _dbHelper.eliminarProducto(id);
    _productos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Descuenta el stock en SQLite y en memoria tras realizar una venta.
  Future<void> descontarStock(String idProducto, int cantidadVendida) async {
    final index = _productos.indexWhere((p) => p.id == idProducto);
    if (index != -1) {
      final actual = _productos[index];
      final nuevoStock = (actual.stock - cantidadVendida).clamp(
        0,
        actual.stock,
      );

      final productoActualizado = Producto(
        id: actual.id,
        codigoBarras: actual.codigoBarras,
        nombre: actual.nombre,
        categoria: actual.categoria,
        precioCosto: actual.precioCosto,
        precioVenta: actual.precioVenta,
        stock: nuevoStock,
      );

      await _dbHelper.actualizarProducto(productoActualizado);
      _productos[index] = productoActualizado;
      notifyListeners();
    }
  }

  Producto? obtenerPorId(String id) {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Producto> get todosLosProductos => List.unmodifiable(_productos);
}
