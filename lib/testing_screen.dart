import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TouchMarkerScreen extends StatefulWidget {
  @override
  _TouchMarkerScreenState createState() => _TouchMarkerScreenState();
}

class _TouchMarkerScreenState extends State<TouchMarkerScreen> {
  List<Offset> touchPoints = []; // Stores touched positions
  int touchCount = 0; // Total touch count

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Touch Marker'),
      ),
      body: Stack(
        children: [
          // Background Image
          GestureDetectorWithImage(
            onTapDown: (details) {
              setState(() {
                touchPoints.add(details.localPosition); // Record touch position
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
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
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
            ),
          ),
        ],
      ),
    );
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