class MovimientoCaja {
  final String id;
  final String tipo; // 'ENTRADA' o 'SALIDA'
  final int monto;
  final String motivo;
  final String fecha;

  MovimientoCaja({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.motivo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'monto': monto,
      'motivo': motivo,
      'fecha': fecha,
    };
  }

  factory MovimientoCaja.fromMap(Map<String, dynamic> map) {
    return MovimientoCaja(
      id: map['id'],
      tipo: map['tipo'],
      monto: map['monto'],
      motivo: map['motivo'],
      fecha: map['fecha'],
    );
  }
}