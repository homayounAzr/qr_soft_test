import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_soft_test/features/take_photo/data/repository/photo_repo_impl.dart';
import 'package:qr_soft_test/features/take_photo/domain/entities/photo.dart';
import 'package:qr_soft_test/features/take_photo/domain/repositories/photo_repository.dart';
import 'package:qr_soft_test/features/take_photo/domain/usecases/save_photo_usecase.dart';
import '../../../../../core/connections/db_connection.dart';
import '../../../../../core/constants/consts.dart';
import '../../../data/data_sources/local_DB_photo_data_source.dart';

part 'camera.event.dart';

part 'camera.state.dart';

/// The CameraBloc interacts with the camera hardware, takes photos, and stores them using the provided photo repository.
class CameraBloc extends Bloc<CameraEvent, CameraState> {

  CameraBloc() : super(CameraInitial()) {
    on<CameraInitialized>(_onInitialized);
    on<CameraDispose>(_onDispose);
    on<TakePhoto>(_onTakePhoto);
  }

  final CameraController _controller = CameraController(
    /// This property give ability to move between front and back camera.
    /// For now we don't need it so just set to back camera that we detect it in [cameras].
    cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back),
    ResolutionPreset.max,
    enableAudio: false,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );
  PhotoRepository photoRepository = PhotoRepositoryImpl(LocalDBPhotoDataSource(databaseConnection: DatabaseConnection()));

  /// Initiation the camera controller.
  void _onInitialized(CameraInitialized event, Emitter<CameraState> emit) async {
    try {
      await _controller.initialize();
      _controller.setDescription(cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back));

      emit(CameraReady(_controller));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  /// Dispose camera controller to release resources when app is in background or inactive.
  void _onDispose(CameraDispose event, Emitter<CameraState> emit) async {
    try {
      await _controller.dispose();
      emit(CameraInitial());
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  /// Take photo and save it's information in local DB.
  void _onTakePhoto(TakePhoto event, Emitter<CameraState> emit) async {
    if (!_controller.value.isInitialized) {
      return null;
    }
    try {
      final XFile picture = await _controller.takePicture();
      Photo photo = Photo(directory: picture.path, name: picture.name, size: await picture.length(), date: DateTime.now());
      SavePhotoUseCase savePhotoUseCase = SavePhotoUseCase(photoRepository, photo);
      savePhotoUseCase.execute();

      emit(PhotoReady(picture,_controller));
    } on CameraException catch (e) {
      print(e.description);
      return null;
    }
  }

}