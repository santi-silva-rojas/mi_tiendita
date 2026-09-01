import 'package:flutter/material.dart';
import '../models/venta.dart';
import '../models/movimiento_caja.dart';
import '../models/cierre_caja.dart';
import '../database/db_helper.dart';

class CajaProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Venta> _ventasTurno = [];
  List<Venta> _historicoVentas = [];
  List<MovimientoCaja> _movimientos = [];
  List<CierreCaja> _cierres = [];

  bool _cajaAbierta = false;
  int _baseInicial = 0;

  CajaProvider() {
    cargarDatos();
  }

  bool get cajaAbierta => _cajaAbierta;
  int get baseInicial => _baseInicial;

  List<Venta> get ventasTurno => List.unmodifiable(_ventasTurno);
  List<Venta> get historicoVentas => List.unmodifiable(_historicoVentas);
  List<MovimientoCaja> get movimientos => List.unmodifiable(_movimientos);
  List<CierreCaja> get cierres => List.unmodifiable(_cierres);

  // --- Métricas del Turno Actual ---
  int get totalVentasEfectivo {
    return _ventasTurno
        .where((v) => v.metodoPago == 'EFECTIVO')
        .fold(0, (sum, item) => sum + item.total);
  }

  int get totalVentasFiado {
    return _ventasTurno
        .where((v) => v.metodoPago == 'FIADO')
        .fold(0, (sum, item) => sum + item.total);
  }

  int get totalEntradas {
    return _movimientos
        .where((m) => m.tipo == 'ENTRADA')
        .fold(0, (sum, item) => sum + item.monto);
  }

  int get totalSalidas {
    return _movimientos
        .where((m) => m.tipo == 'SALIDA')
        .fold(0, (sum, item) => sum + item.monto);
  }

  int get efectivoEsperado {
    if (!_cajaAbierta) return 0;
    return _baseInicial + totalVentasEfectivo + totalEntradas - totalSalidas;
  }

  // --- Métricas Globales / Dashboard ---
  int get totalVentasHistorico {
    return _historicoVentas.fold(0, (sum, item) => sum + item.total);
  }

  int get totalEfectivoHistorico {
    return _historicoVentas
        .where((v) => v.metodoPago == 'EFECTIVO')
        .fold(0, (sum, item) => sum + item.total);
  }

  int get totalFiadoHistorico {
    return _historicoVentas
        .where((v) => v.metodoPago == 'FIADO')
        .fold(0, (sum, item) => sum + item.total);
  }

  double get ticketPromedio {
    if (_historicoVentas.isEmpty) return 0;
    return totalVentasHistorico / _historicoVentas.length;
  }

  Future<void> cargarDatos() async {
    _cierres = await _dbHelper.obtenerCierres();
    _historicoVentas = await _dbHelper.obtenerVentas();
    notifyListeners();
  }

  void abrirCaja(int base) {
    _baseInicial = base;
    _cajaAbierta = true;
    _ventasTurno = [];
    _movimientos = [];
    notifyListeners();
  }

  Future<void> registrarVenta(int total, String metodoPago) async {
    if (!_cajaAbierta) return;
    
    final nuevaVenta = Venta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      total: total,
      metodoPago: metodoPago,
      fecha: DateTime.now().toString().split('.')[0],
    );

    await _dbHelper.insertarVenta(nuevaVenta);
    _ventasTurno.add(nuevaVenta);
    _historicoVentas.add(nuevaVenta);
    notifyListeners();
  }

  Future<void> registrarMovimiento(String tipo, int monto, String motivo) async {
    if (!_cajaAbierta) return;

    final mov = MovimientoCaja(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: tipo,
      monto: monto,
      motivo: motivo,
      fecha: DateTime.now().toString().split('.')[0],
    );
    await _dbHelper.insertarMovimiento(mov);
    _movimientos.add(mov);
    notifyListeners();
  }

  Future<void> realizarCierre(int efectivoReportado) async {
    if (!_cajaAbierta) return;

    final diferencia = efectivoReportado - efectivoEsperado;

    final cierre = CierreCaja(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime.now().toString().split('.')[0],
      baseInicial: _baseInicial,
      ventasEfectivo: totalVentasEfectivo,
      ventasFiado: totalVentasFiado,
      entradas: totalEntradas,
      salidas: totalSalidas,
      totalEsperado: efectivoEsperado,
      totalReportado: efectivoReportado,
      diferencia: diferencia,
    );

    await _dbHelper.insertarCierre(cierre);
    _cierres.add(cierre);

    // Reiniciar turno activo manteniendo el historial persistido
    _cajaAbierta = false;
    _baseInicial = 0;
    _ventasTurno = [];
    _movimientos = [];

    notifyListeners();
  }
}