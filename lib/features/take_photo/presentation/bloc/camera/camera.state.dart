part of 'camera.bloc.dart';

abstract class CameraState {}

class CameraInitial extends CameraState {}

/// state to notify the camera is ready and show it.
class CameraReady extends CameraState {
  final CameraController controller;

  CameraReady(this.controller);
}

class CameraError extends CameraState {
  final String error;

  CameraError(this.error);
}

/// state to pass the photo taken and show it.
/// also change the app state to user be able to navigate to gallery page.
class PhotoReady extends CameraState {
  final CameraController controller;
  final XFile photo;
  final Uint8List? image;

  PhotoReady(this.image, this.photo, this.controller);
}
