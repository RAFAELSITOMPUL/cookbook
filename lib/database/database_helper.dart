import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw Exception('Database SQLite tidak didukung di Web secara langsung.');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: 3, // Naikkan ke versi 3 untuk memastikan pembaruan total
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Hapus tabel jika ada untuk menghindari konflik skema lama
      await db.execute('DROP TABLE IF EXISTS shopping_list');
      await db.execute('DROP TABLE IF EXISTS meal_plan');
      
      // Buat ulang dengan struktur yang benar
      await db.execute('''
        CREATE TABLE shopping_list (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_bahan TEXT,
          jumlah TEXT,
          is_checked INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE meal_plan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          resep_id INTEGER,
          tanggal TEXT,
          FOREIGN KEY (resep_id) REFERENCES resep (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE resep (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_resep TEXT,
        kategori TEXT,
        waktu_memasak INTEGER,
        porsi INTEGER,
        tingkat_kesulitan TEXT,
        deskripsi TEXT,
        gambar TEXT,
        favorit INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bahan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resep_id INTEGER,
        nama_bahan TEXT,
        jumlah TEXT,
        FOREIGN KEY (resep_id) REFERENCES resep (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE langkah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resep_id INTEGER,
        urutan INTEGER,
        deskripsi TEXT,
        FOREIGN KEY (resep_id) REFERENCES resep (id) ON DELETE CASCADE
      )
    ''');

    // Pastikan tabel baru juga dibuat jika ini instalasi baru (versi 2)
    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_bahan TEXT,
        jumlah TEXT,
        is_checked INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_plan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resep_id INTEGER,
        tanggal TEXT,
        FOREIGN KEY (resep_id) REFERENCES resep (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.dbName);
    await deleteDatabase(path);
    _database = null;
    await database;
  }

  Future<String> backupDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    
    final directory = await getApplicationDocumentsDirectory();
    final backupPath = join(directory.path, 'backup_${AppConstants.dbName}');
    
    final file = File(path);
    if (await file.exists()) {
      await file.copy(backupPath);
      return backupPath;
    }
    throw Exception('File database tidak ditemukan');
  }

  Future<void> restoreDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupPath = join(directory.path, 'backup_${AppConstants.dbName}');
    
    final backupFile = File(backupPath);
    if (await backupFile.exists()) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.dbName);
      
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      await backupFile.copy(path);
      await database; // Re-init
    } else {
      throw Exception('File backup tidak ditemukan');
    }
  }

  // Helper methods for direct access
  Future<void> insertMealPlan(int recipeId, String date) async {
    final db = await database;
    await db.insert('meal_plan', {'resep_id': recipeId, 'tanggal': date});
  }
}
