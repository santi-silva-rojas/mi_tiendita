import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/caja_provider.dart';
import '../../../core/providers/clientes_provider.dart';

class PantallaDashboard extends StatelessWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final caja = Provider.of<CajaProvider>(context);
    final clientes = Provider.of<ClientesProvider>(context);

    // Deuda acumulada total de todos los clientes
    final totalDeudaCartera = clientes.clientes.fold(
      0,
      (sum, c) => sum + c.saldoDeuda,
    );

    final ventasReversadas = caja.historicoVentas.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Historial de Ventas y Métricas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General de Rendimiento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tarjetas de Métricas Clave
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _buildMetricCard(
                      'Ventas Totales',
                      '\$${caja.totalVentasHistorico}',
                      '${caja.historicoVentas.length} Transacciones',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _buildMetricCard(
                      'Ingresos en Efectivo',
                      '\$${caja.totalEfectivoHistorico}',
                      'Recibido en Caja',
                      Icons.payments,
                      Colors.blue,
                    ),
                    _buildMetricCard(
                      'Ventas a Crédito',
                      '\$${caja.totalFiadoHistorico}',
                      'Cartera pendiente: \$$totalDeudaCartera',
                      Icons.assignment,
                      Colors.purple,
                    ),
                    _buildMetricCard(
                      'Ticket Promedio',
                      '\$${caja.ticketPromedio.toStringAsFixed(0)}',
                      'Por Venta',
                      Icons.analytics,
                      Colors.orange,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🧾 Registro Histórico de Transacciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total registros: ${caja.historicoVentas.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tabla / Lista de Historial de Ventas
            caja.historicoVentas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No hay transacciones registradas hasta el momento.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 2,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ventasReversadas.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final venta = ventasReversadas[index];
                        final esEfectivo = venta.metodoPago == 'EFECTIVO';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: esEfectivo
                                ? Colors.green.shade100
                                : Colors.purple.shade100,
                            child: Icon(
                              esEfectivo ? Icons.money : Icons.credit_card,
                              color: esEfectivo ? Colors.green : Colors.purple,
                            ),
                          ),
                          title: Text(
                            'Venta #${venta.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Fecha y Hora: ${venta.fecha}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  venta.metodoPago,
                                  style: TextStyle(
                                    color: esEfectivo
                                        ? Colors.green.shade900
                                        : Colors.purple.shade900,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: esEfectivo
                                    ? Colors.green.shade50
                                    : Colors.purple.shade50,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '\$${venta.total}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String titulo,
    String valor,
    String subtitulo,
    IconData icono,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icono, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}