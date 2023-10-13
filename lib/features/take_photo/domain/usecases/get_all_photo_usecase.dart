import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

/// Use case for retrieving all photos from the [PhotoRepository].
/// It doesn't matter where the data originates(DB/Remote)
/// if need extra process here we encapsulates the specific use case of getting all photos.
class GetAllPhotosUseCase {
  final PhotoRepository photoRepository;

  GetAllPhotosUseCase(this.photoRepository);

  Future<List<Photo>> execute() {
    return photoRepository.getAllPhotos();
  }
}
