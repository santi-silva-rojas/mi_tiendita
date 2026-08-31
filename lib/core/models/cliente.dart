class Cliente {
  final String id;
  final String nombre;
  final String telefono;
  final String cedula;
  final int limiteCredito;
  int saldoDeuda;

  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.cedula,
    required this.limiteCredito,
    this.saldoDeuda = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'cedula': cedula,
      'limiteCredito': limiteCredito,
      'saldoDeuda': saldoDeuda,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nombre: map['nombre'],
      telefono: map['telefono'],
      cedula: map['cedula'],
      limiteCredito: map['limiteCredito'],
      saldoDeuda: map['saldoDeuda'],
    );
  }
}