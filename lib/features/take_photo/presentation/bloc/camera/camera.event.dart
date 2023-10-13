part of 'camera.bloc.dart';

abstract class CameraEvent {}

class CameraInitialized extends CameraEvent {}

class CameraDispose extends CameraEvent {}

class TakePhoto extends CameraEvent {}
