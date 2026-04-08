import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/photo_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gps_camera.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        filter_name TEXT
      )
    ''');
  }

  Future<int> insertPhoto(PhotoMetadata photo) async {
    final db = await database;
    return await db.insert('photos', photo.toMap());
  }

  Future<List<PhotoMetadata>> getAllPhotos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'photos',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => PhotoMetadata.fromMap(map)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}
