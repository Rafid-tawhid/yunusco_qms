// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class ImageMarkerScreen extends StatefulWidget {
//   @override
//   _ImageMarkerScreenState createState() => _ImageMarkerScreenState();
// }
//
// class _ImageMarkerScreenState extends State<ImageMarkerScreen> {
//   File? _image;
//   final List<Offset> _marks = [];
//   final GlobalKey _globalKey = GlobalKey();
//   int _markCount = 0;
//
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _marks.clear();
//         _markCount = 0;
//       });
//     }
//   }
//
//   void _addMark(TapDownDetails details) {
//     final RenderBox renderBox = _globalKey.currentContext!.findRenderObject() as RenderBox;
//     final localPosition = renderBox.globalToLocal(details.globalPosition);
//
//     setState(() {
//       _marks.add(localPosition);
//       _markCount = _marks.length;
//     });
//   }
//
//   void _clearMarks() {
//     setState(() {
//       _marks.clear();
//       _markCount = 0;
//     });
//   }
//
//   Future<void> _saveMarkedImage() async {
//     if (_image == null) return;
//
//     // Request storage permission
//     var status = await Permission.storage.request();
//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Permission denied')),
//       );
//       return;
//     }
//
//     try {
//       // Capture the widget as an image
//       RenderRepaintBoundary boundary =
//       _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();
//
//       // Save to gallery
//       // final result = await ImageGallerySaver.saveImage(pngBytes,
//       //     quality: 100, name: 'marked_image_${DateTime.now().millisecondsSinceEpoch}');
//
//       // if (result['isSuccess']) {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(content: Text('Image saved to gallery!')),
//       //   );
//       // } else {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(content: Text('Failed to save image: ${result['error']}')),
//       //   );
//       // }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Marker'),
//         actions: [
//           if (_image != null)
//             IconButton(
//               icon: Icon(Icons.clear),
//               onPressed: _clearMarks,
//               tooltip: 'Clear Marks',
//             ),
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _saveMarkedImage,
//             tooltip: 'Save Image',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text('Mark Count: $_markCount',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ),
//           Expanded(
//             child: Center(
//               child: _image == null
//                   ? Text('Select an image to start marking')
//                   : GestureDetector(
//                 onTapDown: _addMark,
//                 child: RepaintBoundary(
//                   key: _globalKey,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       InteractiveViewer(
//                         child: Image.file(_image!, fit: BoxFit.contain),
//                       ),
//                       CustomPaint(
//                         painter: MarkPainter(_marks),
//                         size: Size.infinite,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _pickImage,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.image),
//       ),
//     );
//   }
// }
//
// class MarkPainter extends CustomPainter {
//   final List<Offset> marks;
//
//   MarkPainter(this.marks);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red.withOpacity(0.7)
//       ..strokeWidth = 5
//       ..style = PaintingStyle.fill;
//
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//     );
//
//     for (int i = 0; i < marks.length; i++) {
//       final mark = marks[i];
//       // Draw circle
//       canvas.drawCircle(mark, 15, paint);
//
//       // Draw number inside circle
//       textPainter.text = TextSpan(
//         text: '${i + 1}',
//         style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//       );
//       textPainter.layout();
//       textPainter.paint(
//         canvas,
//         mark - Offset(textPainter.width / 2, textPainter.height / 2),
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(MarkPainter oldDelegate) {
//     return oldDelegate.marks.length != marks.length;
//   }
// }