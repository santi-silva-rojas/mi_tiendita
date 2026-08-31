import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/fiado.dart';
import '../database/db_helper.dart';
import 'caja_provider.dart';

class ClientesProvider extends ChangeNotifier {
  List<Cliente> _clientes = [];
  List<Fiado> _fiados = [];
  final DBHelper _dbHelper = DBHelper();

  ClientesProvider() {
    cargarDatos();
  }

  List<Cliente> get clientes => List.unmodifiable(_clientes);
  List<Fiado> get fiados => List.unmodifiable(_fiados);

  Future<void> cargarDatos() async {
    _clientes = await _dbHelper.obtenerClientes();
    _fiados = await _dbHelper.obtenerFiados();
    notifyListeners();
  }

  Future<void> agregarCliente(Cliente cliente) async {
    await _dbHelper.insertarCliente(cliente);
    _clientes.add(cliente);
    notifyListeners();
  }

  Future<bool> registrarFiado(String clienteId, int total) async {
    final index = _clientes.indexWhere((c) => c.id == clienteId);
    if (index == -1) return false;

    final cliente = _clientes[index];
    final nuevoSaldo = cliente.saldoDeuda + total;

    if (nuevoSaldo > cliente.limiteCredito) {
      return false; // Excede el cupo permitido
    }

    cliente.saldoDeuda = nuevoSaldo;
    await _dbHelper.actualizarCliente(cliente);

    final nuevoFiado = Fiado(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clienteId: clienteId,
      total: total,
      fecha: DateTime.now().toString().split('.')[0],
    );

    await _dbHelper.insertarFiado(nuevoFiado);
    _fiados.add(nuevoFiado);
    notifyListeners();
    return true;
  }

  Future<bool> registrarAbono(String clienteId, int monto, CajaProvider cajaProvider) async {
    if (!cajaProvider.cajaAbierta) {
      return false; // No se pueden recibir abonos si la caja está cerrada
    }

    final index = _clientes.indexWhere((c) => c.id == clienteId);
    if (index != -1) {
      final cliente = _clientes[index];
      cliente.saldoDeuda = (cliente.saldoDeuda - monto).clamp(0, cliente.saldoDeuda);
      await _dbHelper.actualizarCliente(cliente);

      // Registrar automáticament una entrada de efectivo en el arqueo
      await cajaProvider.registrarMovimiento(
        'ENTRADA',
        monto,
        'Abono a deuda - Cliente: ${cliente.nombre}',
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> editarCliente(Cliente clienteActualizado) async {
    final index = _clientes.indexWhere((c) => c.id == clienteActualizado.id);
    if (index != -1) {
      await _dbHelper.actualizarCliente(clienteActualizado);
      _clientes[index] = clienteActualizado;
      notifyListeners();
    }
  }
}