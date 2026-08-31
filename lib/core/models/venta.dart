class Venta {
  final String id;
  final int total;
  final String metodoPago; // 'EFECTIVO' o 'FIADO'
  final String fecha;

  Venta({
    required this.id,
    required this.total,
    required this.metodoPago,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'metodoPago': metodoPago,
      'fecha': fecha,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      total: map['total'],
      metodoPago: map['metodoPago'],
      fecha: map['fecha'],
    );
  }
}