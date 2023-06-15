// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:math' as math;

class linePainter extends CustomPainter {
  final Offset dots;
  final Offset startPoint;
  final Paint linePaint;

  linePainter(this.dots, this.startPoint, this.linePaint);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the dotted line
    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.lineTo(dots.dx, dots.dy);

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

      canvas.drawPath(dotPath, linePaint);
    }
  }

  @override
  bool shouldRepaint(linePainter oldDelegate) {
    return oldDelegate.dots != dots || oldDelegate.startPoint != startPoint;
  }
}