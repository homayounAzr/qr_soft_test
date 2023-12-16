import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_editor/image_editor.dart';
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
  double? widthRatio;
  double? heightRatio;
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
    imageFormatGroup: ImageFormatGroup.yuv420,
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
      final DateTime startDate = DateTime.now();
      final XFile picture = await _controller.takePicture();
      final ImageEditorOption option = ImageEditorOption();
        if(event.contrast!=0){
          final int bias = Platform.isIOS ? 1 : 255;
          double contrast = 1 + event.contrast;
          option.addOption(ColorOption(matrix: [
          contrast, 0, 0, 0, bias * (0.5 * (1 - contrast)),
          0, contrast, 0, 0, bias * (0.5 * (1 - contrast)),
          0, 0, contrast, 0, bias * (0.5 * (1 - contrast)),
          0, 0, 0, 1, 0
        ]));
        }
        if(event.saturation!=0){
          double saturation = 1 + event.saturation;
          option.addOption(ColorOption(matrix: [
        0.213 + 0.787 * saturation, 0.715 - 0.715 * saturation, 0.072 - 0.072 * saturation, 0, 0,
        0.213 - 0.213 * saturation, 0.715 + 0.285 * saturation, 0.072 - 0.072 * saturation, 0, 0,
        0.213 - 0.213 * saturation, 0.715 - 0.715 * saturation, 0.072 + 0.928 * saturation, 0, 0,
        0, 0, 0, 1, 0
      ]));
        }
        if(event.brightness!=0){
          double brightness = 1 + event.brightness;
          option.addOption(ColorOption(matrix: [
          brightness, 0, 0, 0, 0,
          0, brightness, 0, 0, 0,
          0, 0, brightness, 0, 0,
          0, 0, 0, 1, 0
        ]));
        }
        if(event.hue!=0){
          double cosHue = cos(event.hue * pi);
          double sinHue = sin(event.hue * pi);
          option.addOption(ColorOption(matrix: [
        (0.213) + (cosHue * 0.787) - (sinHue * 0.213),(0.715) - (cosHue * 0.715) - (sinHue * 0.715),(0.072) - (cosHue * 0.072) + (sinHue * 0.928), 0, 0,
        (0.213) - (cosHue * 0.213) + (sinHue * 0.143),(0.715) + (cosHue * 0.285) + (sinHue * 0.140), (0.072) - (cosHue * 0.072) - (sinHue * 0.283), 0, 0,
        (0.213) - (cosHue * 0.213) - (sinHue * 0.787), (0.715) - (cosHue * 0.715) + (sinHue * 0.715),(0.072) + (cosHue * 0.928) + (sinHue * 0.072), 0, 0,
        0, 0, 0, 1, 0,
      ]));
        }
        if(event.sepia!=0){
          double sepia = (1 - event.sepia).clamp(0, 1);
          option.addOption(ColorOption(matrix: [
        0.393 + 0.607 * sepia, 0.769 - 0.769 * sepia, 0.189 - 0.189 * sepia, 0, 0,
        0.349 - 0.349 * sepia, 0.686 + 0.314 * sepia, 0.168 - 0.168 * sepia, 0, 0,
        0.272 - 0.272 * sepia, 0.534 - 0.534 * sepia, 0.131 + 0.869 * sepia, 0, 0,
        0, 0, 0, 1, 0
      ]));
        }
        if (event.end != null && event.start != null && event.start != event.end) {
        Offset start = Offset(min(event.start!.dx, event.end!.dx), min(event.start!.dy, event.end!.dy));
        Offset end = Offset(max(event.start!.dx, event.end!.dx), max(event.start!.dy, event.end!.dy));
        if(widthRatio == null || heightRatio == null){
          var originalImage = await decodeImageFromList(File(picture.path).readAsBytesSync());
          widthRatio = originalImage.width / MediaQuery.of((event.context!)).size.width;
          heightRatio =  originalImage.height / MediaQuery.of((event.context!)).size.height;
        }
        option.addOption(ClipOption(
          x: (start.dx * widthRatio!).toInt(),
          y: (start.dy * heightRatio!).toInt(),
          width: ((end.dx * widthRatio!) - (start.dx * widthRatio!)).toInt(),
          height: ((end.dy * heightRatio!) - (start.dy * heightRatio!)).toInt(),
        ));
      }

        Uint8List?  croppedBytes = await ImageEditor.editImage(
          image: await picture.readAsBytes(),
          imageEditorOption: option,
        );
        File(picture.path).writeAsBytesSync(croppedBytes!.toList());
        Photo croppedPhoto = Photo(directory: picture.path, name: 'cropped.png', size: await picture.length(), date: DateTime.now());
        SavePhotoUseCase saveCroppedPhotoUseCase = SavePhotoUseCase(photoRepository, croppedPhoto);
        saveCroppedPhotoUseCase.execute();

      // Share.shareFiles([picture.path]);
        emit(PhotoReady(croppedBytes, _controller, DateTime.now().difference(startDate).inMilliseconds.toString()));
    } on CameraException catch (e) {
      print(e.description);
      return null;
    }
  }
}