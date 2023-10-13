import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera/camera.bloc.dart';
import 'gallery.dart';

class CameraHome extends StatefulWidget {
  const CameraHome({super.key});

  @override
  State<CameraHome> createState() => _CameraHomeState();
}
/// _CameraHomeState using WidgetsBindingObserver to detect when the app is in foreground or background.
class _CameraHomeState extends State<CameraHome> with WidgetsBindingObserver {
  late CameraBloc _cameraBloc;

  @override
  void initState() {
    super.initState();
    _cameraBloc = CameraBloc()..add(CameraInitialized());
  }

  /// This method is for observe app lifecycle.
  /// When the app is di active call CameraDispose to dispose camera controller
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraBloc.add(CameraDispose());
    } else if (state == AppLifecycleState.resumed) {
      _cameraBloc.add(CameraInitialized());
    }
  }

  @override
  void dispose() {
    _cameraBloc.add(CameraDispose());
    _cameraBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cameraBloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          extendBody: true,
          body: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              if (state is CameraInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CameraError) {
                return Center(child: Text(state.error));
              }
              if (state is CameraReady) {
                return Column(
                  children: [
                    Expanded(child: CameraPreview(state.controller)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.camera_alt,size: 40,),
                            onPressed: () => _cameraBloc.add(TakePhoto())
                        ),
                      ],
                    ),
                  ],
                );
              }
              if (state is PhotoReady) {
                return Column(
                  children: [
                    Expanded(child: CameraPreview(state.controller)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 80),
                          child: IconButton(
                              icon: const Icon(Icons.camera_alt,size: 40,),
                              onPressed: () => _cameraBloc.add(TakePhoto())
                          ),
                        ),
                        InkWell(
                            onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryHome())),
                            child: SizedBox(width: 100, height: 80, child: Image.file(File(state.photo.path)))),
                      ],
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
