class Fiado {
  final String id;
  final String clienteId;
  final int total;
  final String fecha;
  final String estado; // 'PENDIENTE' o 'PAGADO'

  Fiado({
    required this.id,
    required this.clienteId,
    required this.total,
    required this.fecha,
    this.estado = 'PENDIENTE',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'total': total,
      'fecha': fecha,
      'estado': estado,
    };
  }

  factory Fiado.fromMap(Map<String, dynamic> map) {
    return Fiado(
      id: map['id'],
      clienteId: map['clienteId'],
      total: map['total'],
      fecha: map['fecha'],
      estado: map['estado'],
    );
  }
}