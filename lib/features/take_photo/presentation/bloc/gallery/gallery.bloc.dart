import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_soft_test/features/take_photo/data/repository/photo_repo_impl.dart';
import 'package:qr_soft_test/features/take_photo/domain/repositories/photo_repository.dart';
import '../../../../../core/connections/db_connection.dart';
import '../../../data/data_sources/local_DB_photo_data_source.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/usecases/get_all_photo_usecase.dart';

part 'gallery.event.dart';
part 'gallery.state.dart';

/// The GalleryBloc interacts with DB and get all photos using the provided photo repository.
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {

  GalleryBloc() : super(GalleryLoading()) {
    on<GalleryInitialized>(_onInitialized);
  }

  PhotoRepository photoRepository = PhotoRepositoryImpl(LocalDBPhotoDataSource(databaseConnection: DatabaseConnection()));

  /// get all photos from DB and return them.
  void _onInitialized(GalleryInitialized event, Emitter<GalleryState> emit) async {
    try {
      emit(GalleryLoading());
      GetAllPhotosUseCase getAllPhotosUseCase = GetAllPhotosUseCase(photoRepository);
      final photos = await getAllPhotosUseCase.execute();
      emit(GalleryReady(photos));
    } catch (e) {
      print(e.toString());
    }
  }

}