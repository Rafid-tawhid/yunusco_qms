import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageMarkerScreen extends StatefulWidget {
  @override
  _ImageMarkerScreenState createState() => _ImageMarkerScreenState();
}

class _ImageMarkerScreenState extends State<ImageMarkerScreen> {
  File? _image;
  final List<Offset> _marks = [];
  final GlobalKey _globalKey = GlobalKey();
  int _markCount = 0;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _marks.clear();
        _markCount = 0;
      });
    }
  }

  void _addMark(Offset position) {
    setState(() {
      _marks.add(position);
      _markCount = _marks.length;
    });
  }

  Future<void> _saveMarkedImage() async {
    if (_image == null) return;

    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      return;
    }

    // Capture the widget as an image
    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Save to gallery
    final result = await ImageGallerySaver.saveImage(pngBytes);

    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to gallery!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Marker'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveMarkedImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Text('Mark Count: $_markCount', style: TextStyle(fontSize: 20)),
          Expanded(
            child: Center(
              child: _image == null
                  ? Text('No image selected')
                  : GestureDetector(
                onTapDown: (details) {
                  _addMark(details.localPosition);
                },
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Stack(
                    children: [
                      Image.file(_image!),
                      CustomPaint(
                        painter: MarkPainter(_marks),
                        size: Size.infinite,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}

class MarkPainter extends CustomPainter {
  final List<Offset> marks;

  MarkPainter(this.marks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    for (var mark in marks) {
      canvas.drawCircle(mark, 15, paint);
    }
  }


  @override
  bool shouldRepaint(MarkPainter oldDelegate) {
    return oldDelegate.marks != marks;
  }
}

//01716325966