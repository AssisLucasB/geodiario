import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/registro_foto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('geodiario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        caminho_imagem TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');
  }

  Future<int> inserirRegistro(RegistroFoto registro) async {
    final db = await instance.database;
    return await db.insert('registros', registro.toMap());
  }

  Future<List<RegistroFoto>> listarRegistros() async {
    final db = await instance.database;
    final result = await db.query('registros', orderBy: 'id DESC');
    return result.map((map) => RegistroFoto.fromMap(map)).toList();
  }

  Future<int> excluirRegistro(int id) async {
    final db = await instance.database;
    return await db.delete(
      'registros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
