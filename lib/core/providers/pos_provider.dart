import 'package:flutter/material.dart';
import '../models/producto.dart';

/// Modelo para representar un ítem dentro del carrito de compras.
class ItemCarrito {
  final String idProducto;
  final String nombre;
  final int precio;
  int cantidad;
  int stockDisponible;

  ItemCarrito({
    required this.idProducto,
    required this.nombre,
    required this.precio,
    required this.stockDisponible,
    this.cantidad = 1,
  });

  int get subtotal => precio * cantidad;
}

/// Gestor de estado global para la venta actual (POS).
class PosProvider extends ChangeNotifier {
  final List<ItemCarrito> _carrito = [];

  /// Retorna una copia inmutable de los elementos del carrito.
  List<ItemCarrito> get carrito => List.unmodifiable(_carrito);

  /// Retorna la suma total de la venta actual.
  int get totalPagar {
    int total = 0;
    for (var item in _carrito) {
      total += item.subtotal;
    }
    return total;
  }

  /// Retorna la cantidad total de artículos agregados al carrito.
  int get cantidadTotalArticulos {
    int total = 0;
    for (var item in _carrito) {
      total += item.cantidad;
    }
    return total;
  }

  /// Agrega un Producto real al carrito validando stock disponible
  bool agregarProducto(Producto producto) {
    if (producto.stock <= 0) return false;

    int index = _carrito.indexWhere((item) => item.idProducto == producto.id);

    if (index != -1) {
      if (_carrito[index].cantidad < producto.stock) {
        _carrito[index].cantidad += 1;
        _carrito[index].stockDisponible = producto.stock;
        notifyListeners();
        return true;
      }
      return false; // No hay suficiente stock para sumar más
    } else {
      _carrito.add(
        ItemCarrito(
          idProducto: producto.id,
          nombre: producto.nombre,
          precio: producto.precioVenta,
          stockDisponible: producto.stock,
        ),
      );
      notifyListeners();
      return true;
    }
  }

  /// Incrementa en 1 la cantidad validando el stock disponible
  bool aumentarCantidad(int index) {
    if (_carrito[index].cantidad < _carrito[index].stockDisponible) {
      _carrito[index].cantidad += 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Disminuye en 1 la cantidad o remueve el ítem si llega a 0.
  void disminuirCantidad(int index) {
    if (_carrito[index].cantidad > 1) {
      _carrito[index].cantidad -= 1;
    } else {
      _carrito.removeAt(index);
    }
    notifyListeners();
  }

  /// Remueve un producto en específico por su índice.
  void eliminarProducto(int index) {
    _carrito.removeAt(index);
    notifyListeners();
  }

  /// Vacía completamente el carrito de compras.
  void vaciarCarrito() {
    _carrito.clear();
    notifyListeners();
  }
}