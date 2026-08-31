import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/caja_provider.dart';

class PantallaArqueo extends StatefulWidget {
  const PantallaArqueo({super.key});

  @override
  State<PantallaArqueo> createState() => _PantallaArqueoState();
}

class _PantallaArqueoState extends State<PantallaArqueo> {
  final TextEditingController _baseInicialController = TextEditingController();

  final Map<int, TextEditingController> _denominaciones = {
    100000: TextEditingController(text: '0'),
    50000: TextEditingController(text: '0'),
    20000: TextEditingController(text: '0'),
    10000: TextEditingController(text: '0'),
    5000: TextEditingController(text: '0'),
    2000: TextEditingController(text: '0'),
    1000: TextEditingController(text: '0'),
    500: TextEditingController(text: '0'),
    200: TextEditingController(text: '0'),
    100: TextEditingController(text: '0'),
    50: TextEditingController(text: '0'),
  };

  int get totalContado {
    int suma = 0;
    _denominaciones.forEach((valor, ctrl) {
      int cant = int.tryParse(ctrl.text) ?? 0;
      suma += valor * cant;
    });
    return suma;
  }

  void _limpiarConteo() {
    for (var ctrl in _denominaciones.values) {
      ctrl.text = '0';
    }
  }

  void _mostrarModalMovimiento(BuildContext context, String tipo) {
    final montoCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registrar $tipo de Caja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
            ),
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(labelText: 'Motivo / Concepto'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              int monto = int.tryParse(montoCtrl.text) ?? 0;
              if (monto > 0 && motivoCtrl.text.isNotEmpty) {
                Provider.of<CajaProvider>(context, listen: false)
                    .registrarMovimiento(tipo, monto, motivoCtrl.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caja = Provider.of<CajaProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('💵 Gestión de Caja y Arqueo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.point_of_sale), text: 'Turno Actual'),
              Tab(icon: Icon(Icons.history), text: 'Historial de Cierres'),
            ],
          ),
          actions: caja.cajaAbierta
              ? [
                  ElevatedButton.icon(
                    onPressed: () => _mostrarModalMovimiento(context, 'ENTRADA'),
                    icon: const Icon(Icons.add),
                    label: const Text('Entrada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarModalMovimiento(context, 'SALIDA'),
                    icon: const Icon(Icons.remove),
                    label: const Text('Salida'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                ]
              : null,
        ),
        body: TabBarView(
          children: [
            caja.cajaAbierta ? _buildArqueoActivo(caja) : _buildAperturaCaja(caja),
            _buildHistorialCierres(caja),
          ],
        ),
      ),
    );
  }

  Widget _buildAperturaCaja(CajaProvider caja) {
    return Center(
      child: Card(
        elevation: 4,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_open, size: 60, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Apertura de Caja',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _baseInicialController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base Inicial (\$) ',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    int base = int.tryParse(_baseInicialController.text) ?? 0;
                    caja.abrirCaja(base);
                    _baseInicialController.clear();
                    _limpiarConteo();
                  },
                  child: const Text('ABRIR CAJA Y EMPEZAR TURNO', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArqueoActivo(CajaProvider caja) {
    final diferencia = totalContado - caja.efectivoEsperado;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text('📊 Resumen del Turno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _tarjetaInfo('Base Inicial', '\$${caja.baseInicial}', Colors.blue),
                _tarjetaInfo('Ventas en Efectivo', '+\$${caja.totalVentasEfectivo}', Colors.green),
                _tarjetaInfo('Ventas a Crédito (Fiado)', '\$${caja.totalVentasFiado}', Colors.purple),
                _tarjetaInfo('Entradas de Caja', '+\$${caja.totalEntradas}', Colors.teal),
                _tarjetaInfo('Salidas de Caja', '-\$${caja.totalSalidas}', Colors.orange),
                const Divider(height: 30),
                _tarjetaInfo('EFECTIVO ESPERADO EN CAJA', '\$${caja.efectivoEsperado}', Colors.black, esResaltado: true),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🪙 Conteo Físico (Billetes y Monedas)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _denominaciones.length,
                    itemBuilder: (context, index) {
                      int valor = _denominaciones.keys.elementAt(index);
                      TextEditingController ctrl = _denominaciones[valor]!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              Text('\$$valor', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 4)),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Contado:', style: TextStyle(fontSize: 16)),
                          Text('\$$totalContado', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Diferencia / Cuadre:', style: TextStyle(fontSize: 16)),
                          Text(
                            '\$$diferencia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: diferencia == 0
                                  ? Colors.green
                                  : (diferencia > 0 ? Colors.blue : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                    icon: const Icon(Icons.lock),
                    label: const Text('CERRAR CAJA Y GUARDAR', style: TextStyle(fontSize: 16)),
                    onPressed: () async {
                      await caja.realizarCierre(totalContado);
                      _limpiarConteo();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Cierre de caja registrado exitosamente.'), backgroundColor: Colors.green),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialCierres(CajaProvider caja) {
    if (caja.cierres.isEmpty) {
      return const Center(child: Text('No hay cierres de caja registrados aún.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: caja.cierres.length,
      itemBuilder: (context, index) {
        final cierre = caja.cierres.reversed.toList()[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              cierre.diferencia == 0 ? Icons.check_circle : Icons.warning,
              color: cierre.diferencia == 0 ? Colors.green : Colors.red,
            ),
            title: Text('Fecha: ${cierre.fecha}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Base: \$${cierre.baseInicial} | Ventas Efec: \$${cierre.ventasEfectivo} | Fiados: \$${cierre.ventasFiado}\nEntradas: \$${cierre.entradas} | Salidas: \$${cierre.salidas}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Reportado: \$${cierre.totalReportado}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Dif: \$${cierre.diferencia}',
                  style: TextStyle(
                    color: cierre.diferencia == 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tarjetaInfo(String titulo, String valor, Color color, {bool esResaltado = false}) {
    return Card(
      elevation: esResaltado ? 4 : 1,
      color: esResaltado ? color.withOpacity(0.1) : Colors.white,
      child: ListTile(
        title: Text(titulo, style: TextStyle(fontWeight: esResaltado ? FontWeight.bold : FontWeight.normal, fontSize: esResaltado ? 16 : 14)),
        trailing: Text(
          valor,
          style: TextStyle(fontSize: esResaltado ? 20 : 16, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}