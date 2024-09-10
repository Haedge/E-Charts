// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/HittingWidget.dart';
import 'dart:math' as math;

class linePainter extends CustomPainter {
  final Offset dots;
  final Offset startPoint;
  final Paint linePaint;

  linePainter(this.dots, this.startPoint)
              : linePaint = Paint()
                      ..color = Colors.blue
                      ..strokeWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the dotted line
    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.lineTo(dots.dx, dots.dy);
    
    Paint dotPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final Paint paint = Paint()
      ..color = pathtype == 'Ground Ball' ? const Color.fromARGB(227, 0, 0, 0): Colors.red
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1;

    const dashWidth = 5; 
    const dashSpace = 5; 
    final distance = math.sqrt(math.pow(dots.dx - startPoint.dx, 2) + math.pow(dots.dy - startPoint.dy, 2));
    final dotsCount = (distance / (dashWidth + dashSpace)).floor();

    

    for (int i = 0; i < dotsCount; i++) {
      final dotOffset = i / dotsCount;
      final dotPosition = dotOffset * distance;
      final dotPath = Path();
      dotPath.moveTo(startPoint.dx, startPoint.dy);
      dotPath.lineTo(
        startPoint.dx + (dots.dx - startPoint.dx) * dotOffset + dotPosition,
        startPoint.dy + (dots.dy - startPoint.dy) * dotOffset + dotPosition,
      );
      
      canvas.drawPoints(PointMode.points, [startPoint, dots], dotPaint);
      drawDashedLine(canvas: canvas, p1: startPoint, p2: dots, pattern:
      (pathtype == 'Ground Ball' ? [3, 10] : [20,10]), paint: paint);
    }
  }

  @override
  bool shouldRepaint(linePainter oldDelegate) {
    return oldDelegate.dots != dots || oldDelegate.startPoint != startPoint;
  }

  void drawDashedLine({
  required Canvas canvas,
  required Offset p1,
  required Offset p2,
  required Iterable<double> pattern,
  required Paint paint,
}) {
  assert(pattern.length.isEven);
  final distance = (p2 - p1).distance;
  final normalizedPattern = pattern.map((width) => width / distance).toList();
  final points = <Offset>[];
  double t = 0;
  int i = 0;
  while (t < 1) {
    points.add(Offset.lerp(p1, p2, t)!);
    t += normalizedPattern[i++];  // dashWidth
    points.add(Offset.lerp(p1, p2, t.clamp(0, 1))!);
    t += normalizedPattern[i++];  // dashSpace
    i %= normalizedPattern.length;
  }
  canvas.drawPoints(PointMode.lines, points, paint);
}
}