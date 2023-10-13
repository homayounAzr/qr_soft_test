import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/consts.dart';

/// Singleton class to manage the database connection.Here we use Singleton Design Pattern.
/// Provides access to the database instance via the [database] property.
class DatabaseConnection {
  static Database? _database;
  static const columnId = '_id';
  static const columnDirectory = 'photo_directory';
  static const columnName = 'photo_name';
  static const columnDate = 'photo_date';
  static const columnSize = 'photo_size';

  static final DatabaseConnection _instance = DatabaseConnection._internal();

  factory DatabaseConnection() => _instance;

  DatabaseConnection._internal();

  /// Opens the database if needed and returns the instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();
    return _database!;
  }

  /// Initialize a database at the given path.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dataBaseName);

    return await openDatabase(path, version: dataBaseVersion, onCreate: _onCreate);
  }

  /// Create a table to save photos info when database is first created.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $photoTableName (
        $columnId INTEGER PRIMARY KEY,
        $columnDirectory VARCHAR NOT NULL,
        $columnName VARCHAR NOT NULL,
        $columnDate VARCHAR(24) NOT NULL,
        $columnSize INTEGER NOT NULL
      )
    ''');
  }
}
