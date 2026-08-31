import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/producto.dart';
import '../models/cliente.dart';
import '../models/fiado.dart';
import '../models/venta.dart';
import '../models/movimiento_caja.dart';
import '../models/cierre_caja.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'tiendita.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _crearTablasClientes(db);
        }
        if (oldVersion < 3) {
          await _crearTablasArqueo(db);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id TEXT PRIMARY KEY,
        codigoBarras TEXT,
        nombre TEXT,
        categoria TEXT,
        precioCosto INTEGER,
        precioVenta INTEGER,
        stock INTEGER
      )
    ''');
    await _crearTablasClientes(db);
    await _crearTablasArqueo(db);
  }

  Future<void> _crearTablasClientes(Database db) async {
    await db.execute('''
      CREATE TABLE clientes(
        id TEXT PRIMARY KEY,
        nombre TEXT,
        telefono TEXT,
        cedula TEXT,
        limiteCredito INTEGER,
        saldoDeuda INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE fiados(
        id TEXT PRIMARY KEY,
        clienteId TEXT,
        total INTEGER,
        fecha TEXT,
        estado TEXT
      )
    ''');
  }

  Future<void> _crearTablasArqueo(Database db) async {
    await db.execute('''
      CREATE TABLE ventas(
        id TEXT PRIMARY KEY,
        total INTEGER,
        metodoPago TEXT,
        fecha TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE movimientos_caja(
        id TEXT PRIMARY KEY,
        tipo TEXT,
        monto INTEGER,
        motivo TEXT,
        fecha TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cierres_caja(
        id TEXT PRIMARY KEY,
        fecha TEXT,
        baseInicial INTEGER,
        ventasEfectivo INTEGER,
        ventasFiado INTEGER,
        entradas INTEGER,
        salidas INTEGER,
        totalEsperado INTEGER,
        totalReportado INTEGER,
        diferencia INTEGER
      )
    ''');
  }

  // --- MÉTODOS PRODUCTOS ---
  Future<List<Producto>> obtenerProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('productos');
    return List.generate(maps.length, (i) => Producto.fromMap(maps[i]));
  }

  Future<int> insertarProducto(Producto producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> actualizarProducto(Producto producto) async {
    final db = await database;
    return await db.update('productos', producto.toMap(), where: 'id = ?', whereArgs: [producto.id]);
  }

  Future<int> eliminarProducto(String id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS CLIENTES Y FIADOS ---
  Future<List<Cliente>> obtenerClientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clientes');
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  Future<int> insertarCliente(Cliente cliente) async {
    final db = await database;
    return await db.insert('clientes', cliente.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> actualizarCliente(Cliente cliente) async {
    final db = await database;
    return await db.update('clientes', cliente.toMap(), where: 'id = ?', whereArgs: [cliente.id]);
  }

  Future<List<Fiado>> obtenerFiados() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fiados');
    return List.generate(maps.length, (i) => Fiado.fromMap(maps[i]));
  }

  Future<int> insertarFiado(Fiado fiado) async {
    final db = await database;
    return await db.insert('fiados', fiado.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- MÉTODOS VENTAS Y CAJA ---
  Future<List<Venta>> obtenerVentas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ventas');
    return List.generate(maps.length, (i) => Venta.fromMap(maps[i]));
  }

  Future<int> insertarVenta(Venta venta) async {
    final db = await database;
    return await db.insert('ventas', venta.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MovimientoCaja>> obtenerMovimientos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movimientos_caja');
    return List.generate(maps.length, (i) => MovimientoCaja.fromMap(maps[i]));
  }

  Future<int> insertarMovimiento(MovimientoCaja movimiento) async {
    final db = await database;
    return await db.insert('movimientos_caja', movimiento.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CierreCaja>> obtenerCierres() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cierres_caja');
    return List.generate(maps.length, (i) => CierreCaja.fromMap(maps[i]));
  }

  Future<int> insertarCierre(CierreCaja cierre) async {
    final db = await database;
    return await db.insert('cierres_caja', cierre.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}