import 'package:flutter/material.dart';

/// Modelo básico para representar un ítem dentro del carrito de compras.
class ItemCarrito {
  final String nombre;
  final int precio;
  int cantidad;

  ItemCarrito({
    required this.nombre,
    required this.precio,
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

  /// Agrega un producto al carrito o incrementa la cantidad si ya existe.
  void agregarProducto(String nombre, int precio) {
    int index = _carrito.indexWhere((item) => item.nombre == nombre);

    if (index != -1) {
      _carrito[index].cantidad += 1;
    } else {
      _carrito.add(ItemCarrito(nombre: nombre, precio: precio));
    }
    notifyListeners();
  }

  /// Incrementa en 1 la cantidad de un ítem según su índice.
  void aumentarCantidad(int index) {
    _carrito[index].cantidad += 1;
    notifyListeners();
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