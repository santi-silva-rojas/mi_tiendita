class CierreCaja {
  final String id;
  final String fecha;
  final int baseInicial;
  final int ventasEfectivo;
  final int ventasFiado;
  final int entradas;
  final int salidas;
  final int totalEsperado;
  final int totalReportado;
  final int diferencia;

  CierreCaja({
    required this.id,
    required this.fecha,
    required this.baseInicial,
    required this.ventasEfectivo,
    required this.ventasFiado,
    required this.entradas,
    required this.salidas,
    required this.totalEsperado,
    required this.totalReportado,
    required this.diferencia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'baseInicial': baseInicial,
      'ventasEfectivo': ventasEfectivo,
      'ventasFiado': ventasFiado,
      'entradas': entradas,
      'salidas': salidas,
      'totalEsperado': totalEsperado,
      'totalReportado': totalReportado,
      'diferencia': diferencia,
    };
  }

  factory CierreCaja.fromMap(Map<String, dynamic> map) {
    return CierreCaja(
      id: map['id'],
      fecha: map['fecha'],
      baseInicial: map['baseInicial'],
      ventasEfectivo: map['ventasEfectivo'],
      ventasFiado: map['ventasFiado'],
      entradas: map['entradas'],
      salidas: map['salidas'],
      totalEsperado: map['totalEsperado'],
      totalReportado: map['totalReportado'],
      diferencia: map['diferencia'],
    );
  }
}