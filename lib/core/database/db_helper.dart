import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/producto.dart';

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
      version: 1,
      onCreate: _onCreate,
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
  }

  // Cargar todos los productos
  Future<List<Producto>> obtenerProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('productos');
    return List.generate(maps.length, (i) => Producto.fromMap(maps[i]));
  }

  // Insertar producto
  Future<int> insertarProducto(Producto producto) async {
    final db = await database;
    return await db.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actualizar producto
  Future<int> actualizarProducto(Producto producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  // Eliminar producto
  Future<int> eliminarProducto(String id) async {
    final db = await database;
    return await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}