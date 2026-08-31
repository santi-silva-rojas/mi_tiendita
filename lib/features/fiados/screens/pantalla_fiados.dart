import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/clientes_provider.dart';
import '../../../core/providers/caja_provider.dart';
import '../../../core/models/cliente.dart';

class PantallaFiados extends StatelessWidget {
  const PantallaFiados({super.key});

  void _mostrarModalCrearCliente(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final limiteCtrl = TextEditingController(text: '100000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(controller: cedulaCtrl, decoration: const InputDecoration(labelText: 'Cédula / CC')),
            TextField(controller: limiteCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Límite de crédito (\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isNotEmpty) {
                final nuevo = Cliente(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nombre: nombreCtrl.text,
                  telefono: telCtrl.text,
                  cedula: cedulaCtrl.text,
                  limiteCredito: int.tryParse(limiteCtrl.text) ?? 100000,
                );
                Provider.of<ClientesProvider>(context, listen: false).agregarCliente(nuevo);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _mostrarModalEditarCliente(BuildContext context, Cliente cliente) {
    final nombreCtrl = TextEditingController(text: cliente.nombre);
    final telCtrl = TextEditingController(text: cliente.telefono);
    final cedulaCtrl = TextEditingController(text: cliente.cedula);
    final limiteCtrl = TextEditingController(text: cliente.limiteCredito.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Cliente - ${cliente.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(controller: cedulaCtrl, decoration: const InputDecoration(labelText: 'Cédula / CC')),
            TextField(
              controller: limiteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Límite de crédito (\$)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isNotEmpty) {
                final clienteActualizado = Cliente(
                  id: cliente.id,
                  nombre: nombreCtrl.text,
                  telefono: telCtrl.text,
                  cedula: cedulaCtrl.text,
                  limiteCredito: int.tryParse(limiteCtrl.text) ?? cliente.limiteCredito,
                  saldoDeuda: cliente.saldoDeuda,
                );

                Provider.of<ClientesProvider>(context, listen: false)
                    .editarCliente(clienteActualizado);

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Datos del cliente actualizados correctamente'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text('Actualizar'),
          )
        ],
      ),
    );
  }

  void _mostrarModalAbono(BuildContext context, Cliente cliente) {
    final abonoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registrar Abono - ${cliente.nombre}'),
        content: TextField(
          controller: abonoCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monto del abono',
            helperText: 'Deuda actual: \$${cliente.saldoDeuda}',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final monto = int.tryParse(abonoCtrl.text) ?? 0;
              if (monto > 0) {
                final cajaProvider = Provider.of<CajaProvider>(context, listen: false);
                final clientesProvider = Provider.of<ClientesProvider>(context, listen: false);

                bool exito = await clientesProvider.registrarAbono(cliente.id, monto, cajaProvider);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (!exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ No se puede registrar abono: La caja se encuentra cerrada.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Abono registrado y entrada de caja creada.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Registrar Abono'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientesProvider = Provider.of<ClientesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Cuentas por Cobrar (Fiados)'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _mostrarModalCrearCliente(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Nuevo Cliente'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: clientesProvider.clientes.isEmpty
          ? const Center(child: Text('No hay clientes registrados.'))
          : ListView.builder(
              itemCount: clientesProvider.clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientesProvider.clientes[index];
                final tieneDeuda = cliente.saldoDeuda > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tieneDeuda ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        Icons.person,
                        color: tieneDeuda ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(cliente.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('CC: ${cliente.cedula} | Tel: ${cliente.telefono}\nCupo Máx: \$${cliente.limiteCredito}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Saldo Deuda', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '\$${cliente.saldoDeuda}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: tieneDeuda ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Editar Cliente',
                          onPressed: () => _mostrarModalEditarCliente(context, cliente),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: tieneDeuda ? () => _mostrarModalAbono(context, cliente) : null,
                          child: const Text('Abonar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}