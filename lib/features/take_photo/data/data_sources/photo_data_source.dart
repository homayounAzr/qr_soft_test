import '../../domain/entities/photo.dart';

/// Abstract class for photo data source implementations.
/// In a real project, the data source may be from a local database or a remote server.
/// Later, two implementations can be done for this abstract class. for now we just have DB.
abstract class PhotoDataSource {
  Future<List<Photo>> getAllPhotos();

  Future<Photo> getPhoto(int id);

  Future<bool> savePhoto(Photo photo);
}
