import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

/// Use case for save photo info from the [PhotoRepository].
class SavePhotoUseCase {
  final PhotoRepository photoRepository;
  final Photo photo;

  SavePhotoUseCase(this.photoRepository, this.photo);

  Future<bool> execute() {
    return photoRepository.savePhoto(photo);
  }
}
