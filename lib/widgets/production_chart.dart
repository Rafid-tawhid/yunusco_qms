import 'package:flutter/material.dart';



class DualLineChart extends StatelessWidget {
  final List<double> primaryValues;
  final List<double> secondaryValues;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> labels;

  const DualLineChart({
    super.key,
    required this.primaryValues,
    required this.secondaryValues,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.red,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(40, 16, 16, 30),
      child: CustomPaint(
        painter: _DualLineChartPainter(
          primaryValues: primaryValues,
          secondaryValues: secondaryValues,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          labels: labels,
        ),
      ),
    );
  }
}

class _DualLineChartPainter extends CustomPainter {
  final List<double> primaryValues;
  final List<double> secondaryValues;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> labels;

  _DualLineChartPainter({
    required this.primaryValues,
    required this.secondaryValues,
    required this.primaryColor,
    required this.secondaryColor,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = [
      ...primaryValues,
      ...secondaryValues,
    ].reduce((a, b) => a > b ? a : b);

    final minValue = [
      ...primaryValues,
      ...secondaryValues,
    ].reduce((a, b) => a < b ? a : b);

    final range = maxValue - minValue;
    final colWidth = size.width / (primaryValues.length - 1);

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    final textStyle = TextStyle(color: Colors.white, fontSize: 10);

    // Draw horizontal grid lines and left-side value labels
    for (double i = 0; i <= 1; i += 0.25) {
      final y = size.height * (1 - i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final value = (minValue + i * range).toStringAsFixed(0);
      final textSpan = TextSpan(text: value, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-textPainter.width - 4, y - textPainter.height / 2));
    }

    // Draw primary line with points
    _drawLineWithCircles(
      canvas: canvas,
      values: primaryValues,
      color: primaryColor,
      size: size,
      minValue: minValue,
      range: range,
      colWidth: colWidth,
    );

    // Draw secondary line with points
    _drawLineWithCircles(
      canvas: canvas,
      values: secondaryValues,
      color: secondaryColor,
      size: size,
      minValue: minValue,
      range: range,
      colWidth: colWidth,
    );

    // Draw bottom labels (time)
    for (int i = 0; i < labels.length; i++) {
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = colWidth * i - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(x, size.height + 5));
    }
  }

  void _drawLineWithCircles({
    required Canvas canvas,
    required List<double> values,
    required Color color,
    required Size size,
    required double minValue,
    required double range,
    required double colWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = colWidth * i;
      final y = size.height - ((values[i] - minValue) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw filled circles on each point
    for (int i = 0; i < values.length; i++) {
      final x = colWidth * i;
      final y = size.height - ((values[i] - minValue) / range * size.height);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
