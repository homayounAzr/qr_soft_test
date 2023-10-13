import '../../../../core/connections/db_connection.dart';
import '../../../../core/constants/consts.dart';
import '../../domain/entities/photo.dart';
import 'package:sqflite/sqflite.dart';
import 'photo_data_source.dart';

/// Implements [PhotoDataSource] to provide access to photos in local SQLite database.
class LocalDBPhotoDataSource implements PhotoDataSource {
  final DatabaseConnection databaseConnection;

  LocalDBPhotoDataSource({required this.databaseConnection});

  /// Gets all photos stored in the database.
  @override
  Future<List<Photo>> getAllPhotos() async {
    final db = await databaseConnection.database;
    final result = await db.query(photoTableName);
    // print(result);
    return result.map((json) => Photo.fromMap(json)).toList();
  }

  /// Gets a single photo by id. based on the test description we don't need this method for now
  /// But i am sure that it will be needed in a real project.
  @override
  Future<Photo> getPhoto(int id) async {
    final db = await databaseConnection.database;

    final maps = await db.rawQuery('SELECT * FROM $photoTableName WHERE _id = ?', [id]);

    if (maps.isNotEmpty) {
      return Photo.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  /// Saves a new [Photo] to the database.
  @override
  Future<bool> savePhoto(Photo photo) async {
    try {
      final db = await databaseConnection.database;
      await db.insert(photoTableName, photo.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
