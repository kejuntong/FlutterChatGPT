import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../image_edit_service.dart';

class ImageEditScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ImageEditScreenState();

  final Uint8List imageBytes;
  final Uint8List bgImageBytes;
  final ui.Image image;
  final ui.Image bgImage;

  ImageEditScreen({
    Key? key,
    required this.imageBytes,
    required this.bgImageBytes,
    required this.image,
    required this.bgImage,
  }) : super(key: key);

  GlobalKey bgImageKey = GlobalKey();
  GlobalKey imageKey = GlobalKey();
  GlobalKey bgImageEraserKey = GlobalKey();
  GlobalKey imageEraserKey = GlobalKey();
}

class _ImageEditScreenState extends State<ImageEditScreen> {

  Uint8List? screenshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Center(
            child: FittedBox(
              child: SizedBox(
                width: widget.image.width.toDouble(),
                height: widget.image.height.toDouble(),
                child: Consumer(
                  builder: (context, ref, child) {
                    return GestureDetector(
                      onPanStart: (details) {
                        final imageEditService =
                        ref.read(imageEditProvider.notifier);
                        imageEditService.startEdit(details.localPosition);
                      },
                      onPanUpdate: (details) {
                        final imageEditService =
                        ref.read(imageEditProvider.notifier);
                        imageEditService.updateEdit(details.localPosition);
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            // Positioned.fill(
                            //   child: RepaintBoundary(
                            //     key: bgImageKey,
                            //     child: ImageEditPaint(
                            //       canvasPaths: [],
                            //       image: bgImage,
                            //     ),
                            //   ),
                            // ),
                            Positioned.fill(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final imageEditState =
                                  ref.watch(imageEditProvider);
                                  return RepaintBoundary(
                                    key: widget.imageEraserKey,
                                    child: ImageEditPaint(
                                      canvasPaths: imageEditState.eraserPath,
                                      image: widget.image,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          screenshot == null ? const SizedBox(height: 30,) : Image.memory(screenshot!),
          Center(
            child: Consumer(
              builder: (context, ref, child) {
                return Row(
                  children: [
                    ElevatedButton(
                      child: const Text(
                        'undo',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      onPressed: () {
                        final imageEditService =
                        ref.read(imageEditProvider.notifier);
                        imageEditService.undo();
                      },
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton(
                      child: const Text(
                        'test screenshot',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      onPressed: () async {
                        Uint8List imageBytes = await takeScreenShot(widget.imageEraserKey);
                        setState(() {
                          screenshot = imageBytes;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> takeScreenShot(GlobalKey screenshotKey) async {
    RenderRepaintBoundary boundary = screenshotKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }
}

class ImageEditPaint extends StatelessWidget {
  final List<PlaygroundEraserCanvasPath> canvasPaths;
  final ui.Image image;

  const ImageEditPaint({
    Key? key,
    required this.canvasPaths,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      isComplex: true,
      willChange: true,
      foregroundPainter: EraserPainter(
        canvasPaths: canvasPaths,
        image: image,
      ),
    );
  }
}

class EraserPainter extends CustomPainter {
  final List<PlaygroundEraserCanvasPath> canvasPaths;
  final ui.Image image;

  EraserPainter({
    required this.canvasPaths,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawImage(
      image,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.high,
    );
    if (canvasPaths.isNotEmpty) {
      for (var canvasPath in canvasPaths) {
        if (canvasPath.drawPoints.isNotEmpty) {
          var eraserPaint = Paint()
            ..strokeWidth = 50
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..blendMode = BlendMode.clear;
          for (int i = 0; i < canvasPath.drawPoints.length; i++) {
            Offset drawPoint = canvasPath.drawPoints[i];
            if (canvasPath.drawPoints.length > 1) {
              if (i == 0) {
                canvas.drawLine(drawPoint, drawPoint, eraserPaint);
              } else {
                canvas.drawLine(
                    canvasPath.drawPoints[i - 1], drawPoint, eraserPaint);
              }
            } else {
              canvas.drawLine(drawPoint, drawPoint, eraserPaint);
            }
          }
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EraserPainter oldDelegate) => true;
}