import 'package:camera/camera.dart';

/// Name used for the app's SQLite database file.
const dataBaseName = 'myDatabase.db';

/// Name of the table used to store photo info.
const photoTableName = 'photos';

/// Version number used to manage database migrations.
const dataBaseVersion = 1;

/// List of cameras available on the device.
/// Populated at app startup (main method).
List<CameraDescription> cameras = <CameraDescription>[];