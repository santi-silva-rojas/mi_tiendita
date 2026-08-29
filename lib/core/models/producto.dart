

/// Modelo de datos para representar un producto en el inventario.
class Producto {
  final String id;
  String codigoBarras;
  String nombre;
  String categoria;
  int precioCosto;
  int precioVenta;
  int stock;

  Producto({
    required this.id,
    required this.codigoBarras,
    required this.nombre,
    required this.categoria,
    required this.precioCosto,
    required this.precioVenta,
    required this.stock,
  });

  /// Calcula la ganancia bruta por unidad.
  int get gananciaUnitaria => precioVenta - precioCosto;
}