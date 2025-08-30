import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class TouchMarkerScreen extends StatefulWidget {
  @override
  _TouchMarkerScreenState createState() => _TouchMarkerScreenState();
}

class _TouchMarkerScreenState extends State<TouchMarkerScreen> {
  List<Offset> touchPoints = []; // Stores touched positions
  int touchCount = 0; // Total touch count
  final GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Touch Marker')),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                children: [
                  // Background Image
                  GestureDetectorWithImage(
                    onTapDown: (details) {
                      setState(() {
                        touchPoints.add(
                          details.localPosition,
                        ); // Record touch position
                        touchCount++; // Increment touch count
                      });
                    },
                  ),
                  // Touch markers (red circles)
                  ...touchPoints.map(
                    (point) => Positioned(
                      left: point.dx - 15, // Center the marker
                      top: point.dy - 15,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Touch counter (top-right corner)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Touches: $touchCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Clear button (bottom-center)
                ],
              ),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    touchPoints.clear(); // Clear all markers
                    touchCount = 0; // Reset counter
                  });
                },
                child: Text('Clear Markers'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveLocalImage();
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveLocalImage() async {
    try {
      // Request storage permission
      // final status = await Permission.storage.request();
      // if (!status.isGranted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Permission denied')),
      //   );
      //   return;
      // }

      // Get the render object from repaint boundary
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Convert to image
      final ui.Image image = await boundary.toImage(
        pixelRatio: 3.0,
      ); // Higher quality
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to capture image');
      }

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        byteData.buffer.asUint8List(),
        name: 'touch_marker_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );

      // if (result.isSuccess) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Saved to: ${result.filePath}')),
      //   );
      // } else {
      //   throw Exception(result.errorMessage ?? 'Failed to save image');
      // }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}

class GestureDetectorWithImage extends StatelessWidget {
  final Function(TapDownDetails) onTapDown;

  const GestureDetectorWithImage({required this.onTapDown});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/icon.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
