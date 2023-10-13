import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

/// Use case for retrieving specific photo using its id in DB from the [PhotoRepository].
/// if need extra process here we encapsulates the specific use case of getting all photos.
/// for now this is not used in the app.
class GetPhotoUseCase {
  final PhotoRepository photoRepository;
  final int photoId;

  GetPhotoUseCase(this.photoRepository, this.photoId);

  Future<Photo> execute() {
    return photoRepository.getPhoto(photoId);
  }
}
