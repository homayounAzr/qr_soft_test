import '../../domain/entities/photo.dart';

abstract class PhotoRepository {
  Future<List<Photo>> getAllPhotos();

  Future<Photo> getPhoto(int id);

  Future<bool> savePhoto(Photo photo);
}
