import 'dart:io';
import 'dart:math';

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
  bool _cropMode = false;
  bool _focusMode = false;
  Offset? _startPoint = const Offset(0, 0);
  Offset? _endPoint = const Offset(0, 0);
  double _contrast = 0.0;
  double _brightness = 0.0;
  double _saturation = 0.0;
  double _hue = 0.0;
  double _sepia = 0.0;
  double sw = 0;
  double sh = 0;

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

  void _startDrawing(Offset startPoint) {
    setState(() {
      _startPoint = startPoint;
      _endPoint = null;
    });
  }

  void _updateDrawing(Offset updatedPoint) {
    setState(() {
      _endPoint = updatedPoint;
    });
  }

  void _endDrawing() {
    Offset start = Offset(min(_startPoint!.dx, _endPoint!.dx), min(_startPoint!.dy, _endPoint!.dy));
    Offset end = Offset(max(_startPoint!.dx, _endPoint!.dx), max(_startPoint!.dy, _endPoint!.dy));
    double width = end.dx - start.dx;
    double height = end.dy - start.dy;
    double midX = start.dx + width / 2;
    double midY = start.dy + height / 2;
    Offset middlePoint = Offset(midX / sw, midY / sh);
    _cameraBloc.add(ChangeFocus(focusOffset: middlePoint));
  }

  @override
  void dispose() {
    _cameraBloc.add(CameraDispose());
    _cameraBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sw = MediaQuery.of(context).size.width;
    sh = MediaQuery.of(context).size.height;
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
                    Expanded(
                        child: Stack(
                      children: [
                        MaterialApp(
                          home: ColorFiltered(
                            colorFilter: CustomColorMatrixFilter.adjustAll(
                                contrast: _contrast,
                                saturation: _saturation,
                                brightness: _brightness,
                                hue: _hue,
                                sepia: _sepia),
                            child: CameraPreview(state.controller),
                          ),
                        ),
                        _cropMode
                            ? SizedBox(
                                height: 600,
                                width: 500,
                                child: DrawingOverlay(
                                  startPoint: _startPoint,
                                  endPoint: _endPoint,
                                  onStartDrawing: _startDrawing,
                                  onUpdateDrawing: _updateDrawing,
                                  onEndDrawing: _endDrawing,
                                ),
                              )
                            : _focusMode
                                ? LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) {
                                        final offset = Offset(
                                          details.localPosition.dx / constraints.maxWidth,
                                          details.localPosition.dy / constraints.maxHeight,
                                        );
                                        print(offset);
                                        _cameraBloc.add(ChangeFocus(focusOffset: offset));
                                      },
                                    );
                                  })
                                : Container(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _cropMode = false;
                                          _startPoint = _endPoint = null;
                                          _focusMode = !_focusMode;
                                        });
                                      },
                                      child: SizedBox(
                                          width: 100,
                                          height: 80,
                                          child: Icon(
                                            Icons.center_focus_strong_rounded,
                                            color: _focusMode ? Colors.purpleAccent : Colors.blue,
                                          ))),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _focusMode = false;
                                          _cropMode = !_cropMode;
                                          _startPoint = _endPoint = null;
                                        });
                                      },
                                      child: SizedBox(
                                          width: 100,
                                          height: 80,
                                          child: Icon(
                                            Icons.crop,
                                            color: _cropMode ? Colors.purpleAccent : Colors.blue,
                                          ))),
                                  IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _cameraBloc.add(TakePhoto(
                                            start: _startPoint,
                                            end: _endPoint,
                                            context: context,
                                            contrast: _contrast,
                                            brightness: _brightness,
                                            saturation: _saturation,
                                            hue: _hue,
                                            sepia: _sepia,
                                          ))),
                                ],
                              ),
                              _buildSlider('Contrast', _contrast,
                                  (value) => setState(() => _contrast = value)),
                              _buildSlider('Saturation', _saturation,
                                  (value) => setState(() => _saturation = value)),
                              _buildSlider('Brightness', _brightness,
                                  (value) => setState(() => _brightness = value)),
                              _buildSlider('Hue', _hue, (value) => setState(() => _hue = value)),
                              _buildSlider(
                                  'Sepia', _sepia, (value) => setState(() => _sepia = value)),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ],
                );
              }
              if (state is PhotoReady) {
                return Column(
                  children: [
                    Expanded(
                        child: Stack(
                      children: [
                        MaterialApp(
                          home: ColorFiltered(
                            colorFilter: CustomColorMatrixFilter.adjustAll(
                                contrast: _contrast,
                                saturation: _saturation,
                                brightness: _brightness,
                                hue: _hue,
                                sepia: _sepia),
                            child: CameraPreview(state.controller),
                          ),
                        ),
                        _cropMode
                            ? SizedBox(
                                height: 600,
                                width: 500,
                                child: DrawingOverlay(
                                  startPoint: _startPoint,
                                  endPoint: _endPoint,
                                  onStartDrawing: _startDrawing,
                                  onUpdateDrawing: _updateDrawing,
                                  onEndDrawing: _endDrawing,
                                ),
                              )
                            : _focusMode
                                ? LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) {
                                        final offset = Offset(
                                          details.localPosition.dx / constraints.maxWidth,
                                          details.localPosition.dy / constraints.maxHeight,
                                        );
                                        _cameraBloc.add(ChangeFocus(focusOffset: offset));
                                      },
                                    );
                                  })
                                : Container(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _cropMode = false;
                                          _startPoint = _endPoint = null;
                                          _focusMode = !_focusMode;
                                        });
                                      },
                                      child: SizedBox(
                                          width: 100,
                                          height: 80,
                                          child: Icon(
                                            Icons.center_focus_strong_rounded,
                                            color: _focusMode ? Colors.purpleAccent : Colors.blue,
                                          ))),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _focusMode = false;
                                          _cropMode = !_cropMode;
                                          _startPoint = _endPoint = null;
                                        });
                                      },
                                      child: SizedBox(
                                          width: 100,
                                          height: 80,
                                          child: Icon(
                                            Icons.crop,
                                            color: _cropMode ? Colors.purpleAccent : Colors.blue,
                                          ))),
                                  IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _cameraBloc.add(TakePhoto(
                                            start: _startPoint,
                                            end: _endPoint,
                                            context: context,
                                            contrast: _contrast,
                                            brightness: _brightness,
                                            saturation: _saturation,
                                            hue: _hue,
                                            sepia: _sepia,
                                          ))),
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const GalleryHome())),
                                    child: SizedBox(
                                      width: 100,
                                      height: 80,
                                      child: Image.memory(
                                        state.image!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              _buildSlider('Contrast', _contrast,
                                  (value) => setState(() => _contrast = value)),
                              _buildSlider('Saturation', _saturation,
                                  (value) => setState(() => _saturation = value)),
                              _buildSlider('Brightness', _brightness,
                                  (value) => setState(() => _brightness = value)),
                              _buildSlider('Hue', _hue, (value) => setState(() => _hue = value)),
                              _buildSlider(
                                  'Sepia', _sepia, (value) => setState(() => _sepia = value)),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            state.time ?? '_',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
                          ),
                        ),
                      ],
                    )),
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

class DrawingOverlay extends StatelessWidget {
  final Offset? startPoint;
  final Offset? endPoint;
  final Function(Offset) onStartDrawing;
  final Function(Offset) onUpdateDrawing;
  final Function onEndDrawing;

  const DrawingOverlay({
    super.key,
    required this.onStartDrawing,
    required this.onUpdateDrawing,
    required this.onEndDrawing,
    this.startPoint,
    this.endPoint,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => onStartDrawing(details.localPosition),
      onPanUpdate: (details) => onUpdateDrawing(details.localPosition),
      onPanEnd: (details) => onEndDrawing(),
      child: CustomPaint(
        painter: DrawingPainter(startPoint, endPoint),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final Offset? startPoint;
  final Offset? endPoint;

  DrawingPainter(this.startPoint, this.endPoint);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (startPoint != null && endPoint != null) {
      canvas.drawRect(Rect.fromPoints(startPoint!, endPoint!), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: Colors.purpleAccent),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: -1.0,
            max: 1.0,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(color: Colors.purpleAccent),
        ),
      ],
    ),
  );
}

class CustomColorMatrixFilter extends ColorFilter {
  /// helper websites:
  /// https://github.com/iyegoroff/rn-color-matrices/blob/master/index.ts#L210
  /// https://fecolormatrix.com/

  CustomColorMatrixFilter.matrix(List<double> matrix) : super.matrix(matrix);

  factory CustomColorMatrixFilter.adjustAll({
    double contrast = 0.0,
    double saturation = 0.0,
    double brightness = 0.0,
    double hue = 0.0,
    double sepia = 0.0,
  }) {
    final int bias = Platform.isIOS ? 1 : 255;
    double c = 1 + contrast;
    double s = 1 + saturation;
    double b = 1 + brightness;
    double cv = (1 - sepia).clamp(0, 1);
    double cosH = cos(hue * pi);
    double sinH = sin(hue * pi);

    List<double> contrastMatrix = [
      c,
      0,
      0,
      0,
      bias * (0.5 * (1 - c)),
      0,
      c,
      0,
      0,
      bias * (0.5 * (1 - c)),
      0,
      0,
      c,
      0,
      bias * (0.5 * (1 - c)),
      0,
      0,
      0,
      1,
      0
    ];

    List<double> saturationMatrix = [
      0.213 + 0.787 * s,
      0.715 - 0.715 * s,
      0.072 - 0.072 * s,
      0,
      0,
      0.213 - 0.213 * s,
      0.715 + 0.285 * s,
      0.072 - 0.072 * s,
      0,
      0,
      0.213 - 0.213 * s,
      0.715 - 0.715 * s,
      0.072 + 0.928 * s,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ];

    List<double> brightnessMatrix = [b, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 1, 0];

    List<double> hueMatrix = [
      (0.213) + (cosH * 0.787) - (sinH * 0.213),
      (0.715) - (cosH * 0.715) - (sinH * 0.715),
      (0.072) - (cosH * 0.072) + (sinH * 0.928),
      0,
      0,
      (0.213) - (cosH * 0.213) + (sinH * 0.143),
      (0.715) + (cosH * 0.285) + (sinH * 0.140),
      (0.072) - (cosH * 0.072) - (sinH * 0.283),
      0,
      0,
      (0.213) - (cosH * 0.213) - (sinH * 0.787),
      (0.715) - (cosH * 0.715) + (sinH * 0.715),
      (0.072) + (cosH * 0.928) + (sinH * 0.072),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    List<double> sepiaMatrix = [
      0.393 + 0.607 * cv,
      0.769 - 0.769 * cv,
      0.189 - 0.189 * cv,
      0,
      0,
      0.349 - 0.349 * cv,
      0.686 + 0.314 * cv,
      0.168 - 0.168 * cv,
      0,
      0,
      0.272 - 0.272 * cv,
      0.534 - 0.534 * cv,
      0.131 + 0.869 * cv,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ];

    List<double> combinedMatrix = multiplyMatrices(contrastMatrix, brightnessMatrix);
    combinedMatrix = multiplyMatrices(combinedMatrix, saturationMatrix);
    combinedMatrix = multiplyMatrices(combinedMatrix, hueMatrix);
    combinedMatrix = multiplyMatrices(combinedMatrix, sepiaMatrix);

    return CustomColorMatrixFilter.matrix(combinedMatrix);
  }

  static List<double> multiplyMatrices(List<double> matrix1, List<double> matrix2) {
    List<double> result = List.filled(20, 0);

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        result[row * 5 + col] = matrix1[row * 5] * matrix2[col] +
            matrix1[row * 5 + 1] * matrix2[5 + col] +
            matrix1[row * 5 + 2] * matrix2[2 * 5 + col] +
            matrix1[row * 5 + 3] * matrix2[3 * 5 + col] +
            (col == 4 ? matrix1[row * 5 + 4] : 0);
      }
    }

    return result;
  }

  factory CustomColorMatrixFilter.contrast(double contrast) {
    double c = 1 + contrast;
    final int bias = Platform.isIOS ? 1 : 255;
    return CustomColorMatrixFilter.matrix(<double>[
      c,
      0,
      0,
      0,
      bias * (0.5 * (1 - c)),
      0,
      c,
      0,
      0,
      bias * (0.5 * (1 - c)),
      0,
      0,
      c,
      0,
      bias * (0.5 * (1 - c)),
      0,
      0,
      0,
      1,
      0
    ]);
  }

  factory CustomColorMatrixFilter.saturation(double saturation) {
    double s = 1 + saturation;
    return CustomColorMatrixFilter.matrix(<double>[
      0.213 + 0.787 * s,
      0.715 - 0.715 * s,
      0.072 - 0.072 * s,
      0,
      0,
      0.213 - 0.213 * s,
      0.715 + 0.285 * s,
      0.072 - 0.072 * s,
      0,
      0,
      0.213 - 0.213 * s,
      0.715 - 0.715 * s,
      0.072 + 0.928 * s,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ]);
  }

  factory CustomColorMatrixFilter.brightness(double brightness) {
    double b = 1 + brightness;
    return CustomColorMatrixFilter.matrix(
        <double>[b, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 1, 0]);
  }

  factory CustomColorMatrixFilter.hue(double hue) {
    double cosH = cos(hue * pi);
    double sinH = sin(hue * pi);
    return CustomColorMatrixFilter.matrix(<double>[
      (0.213) + (cosH * 0.787) - (sinH * 0.213),
      (0.715) - (cosH * 0.715) - (sinH * 0.715),
      (0.072) - (cosH * 0.072) + (sinH * 0.928),
      0,
      0,
      (0.213) - (cosH * 0.213) + (sinH * 0.143),
      (0.715) + (cosH * 0.285) + (sinH * 0.140),
      (0.072) - (cosH * 0.072) - (sinH * 0.283),
      0,
      0,
      (0.213) - (cosH * 0.213) - (sinH * 0.787),
      (0.715) - (cosH * 0.715) + (sinH * 0.715),
      (0.072) + (cosH * 0.928) + (sinH * 0.072),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  factory CustomColorMatrixFilter.sepia(double sepia) {
    double cv = (1 - sepia).clamp(0, 1);

    return CustomColorMatrixFilter.matrix(<double>[
      0.393 + 0.607 * cv,
      0.769 - 0.769 * cv,
      0.189 - 0.189 * cv,
      0,
      0,
      0.349 - 0.349 * cv,
      0.686 + 0.314 * cv,
      0.168 - 0.168 * cv,
      0,
      0,
      0.272 - 0.272 * cv,
      0.534 - 0.534 * cv,
      0.131 + 0.869 * cv,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ]);
  }
}
