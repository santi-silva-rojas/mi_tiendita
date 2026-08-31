import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/producto.dart';
import '../models/cliente.dart';
import '../models/fiado.dart';

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _crearTablasClientes(db);
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
}