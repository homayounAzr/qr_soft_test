import '../../domain/repositories/photo_repository.dart';
import '../data_sources/photo_data_source.dart';
import '../../domain/entities/photo.dart';

/// Implementation of [PhotoRepository] using a [PhotoDataSource].
/// We don't need to modify any data so the methods are simply return data.
class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoDataSource photoDataSource;

  PhotoRepositoryImpl(this.photoDataSource);

  @override
  Future<List<Photo>> getAllPhotos() {
    return photoDataSource.getAllPhotos();
  }

  @override
  Future<Photo> getPhoto(int id) {
    return photoDataSource.getPhoto(id);
  }

  @override
  Future<bool> savePhoto(Photo photo) {
    return photoDataSource.savePhoto(photo);
  }
}
