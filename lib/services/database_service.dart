import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'users';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTable,
      onUpgrade: _upgradeDatabase,
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rm TEXT UNIQUE NOT NULL,
        senha TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE ocorrencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        laboratorio TEXT NOT NULL,
        andar TEXT NOT NULL,
        problema TEXT NOT NULL,
        patrimonio TEXT NOT NULL,
        dataEnvio TEXT NOT NULL,
        resolvida INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE ocorrencias (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          laboratorio TEXT NOT NULL,
          andar TEXT NOT NULL,
          problema TEXT NOT NULL,
          patrimonio TEXT NOT NULL,
          dataEnvio TEXT NOT NULL,
          resolvida INTEGER DEFAULT 0
        )
      ''');
    }
  }

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> registerUser(String rm, String senha) async {
    try {
      final db = await database;
      String hashedPassword = _hashPassword(senha);
      
      // Verifica se já existe antes de tentar inserir
      if (await userExists(rm)) {
        return false;
      }
      
      await db.insert(
        _tableName,
        {'rm': rm, 'senha': hashedPassword},
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {

      return false;
    }
  }

  static Future<User?> loginUser(String rm, String senha) async {
    try {
      final db = await database;
      String hashedPassword = _hashPassword(senha);
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'rm = ? AND senha = ?',
        whereArgs: [rm, hashedPassword],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> userExists(String rm) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'rm = ?',
        whereArgs: [rm],
      );
      return maps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Métodos para ocorrências
  static Future<int> insertOcorrencia(Map<String, dynamic> ocorrencia) async {
    final db = await database;
    return await db.insert('ocorrencias', ocorrencia);
  }

  static Future<List<Map<String, dynamic>>> getOcorrencias() async {
    final db = await database;
    return await db.query('ocorrencias', orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> getOcorrenciasPendentes() async {
    final db = await database;
    return await db.query('ocorrencias', where: 'resolvida = ?', whereArgs: [0], orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> getOcorrenciasSolucionadas() async {
    final db = await database;
    return await db.query('ocorrencias', where: 'resolvida = ?', whereArgs: [1], orderBy: 'id DESC');
  }

  static Future<void> marcarOcorrenciaResolvida(int id) async {
    final db = await database;
    await db.update('ocorrencias', {'resolvida': 1}, where: 'id = ?', whereArgs: [id]);
  }
}