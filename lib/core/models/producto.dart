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

  /// Convierte el objeto a Map para guardar en la base de datos SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'categoria': categoria,
      'precioCosto': precioCosto,
      'precioVenta': precioVenta,
      'stock': stock,
    };
  }

  /// Crea un objeto Producto desde un Map de la base de datos SQLite.
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      codigoBarras: map['codigoBarras'],
      nombre: map['nombre'],
      categoria: map['categoria'],
      precioCosto: map['precioCosto'],
      precioVenta: map['precioVenta'],
      stock: map['stock'],
    );
  }
}