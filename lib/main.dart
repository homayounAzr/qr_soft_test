import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/consts.dart';
import 'features/take_photo/presentation/pages/camera.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();  /// Initialize binding observer that used in [CameraHome()] class.
    cameras = await availableCameras(); /// Global variable to list all available cameras in the phone.
  } on CameraException catch (e) {
    print(e.code);
    print(e.description);
  }
  /// Hide status bar to show the camera on full screen.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []).then((_) {
    runApp(const CameraHome());
  });
}
