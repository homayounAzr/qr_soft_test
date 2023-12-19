part of 'camera.bloc.dart';

abstract class CameraEvent {}

class CameraInitialized extends CameraEvent {}

class CameraDispose extends CameraEvent {}

class TakePhoto extends CameraEvent {
  final Offset? start;
  final Offset? end;
  final BuildContext? context;
  final double contrast;
  final double brightness;
  final double saturation;
  final double hue;
  final double sepia;
  TakePhoto({this.start, this.end, this.context, required this.contrast, required this.brightness, required this.saturation, required this.hue, required this.sepia});
}

class ChangeFocus extends CameraEvent {
  Offset focusOffset;
  ChangeFocus({required this.focusOffset});

}
