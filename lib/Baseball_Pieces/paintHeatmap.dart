// ignore_for_file: camel_case_types, file_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';

class paintHeatmap extends CustomPainter{
  List<Pitch> pitches;
  BuildContext context;
  final int gridCols;
  final int gridRows;
  final List<MaterialColor> gradientColors;
  final List<double> intensityRanges;
    
  paintHeatmap(this.pitches, this.context,
              {
               this.gridCols = 100,
               this.gridRows = 100,
               this.gradientColors = const [Colors.blue, Colors.yellow, Colors.red],
               this.intensityRanges = const [0, 0.2, 0.6, 1],
              }
  );

  List<Offset> getLocs(List<Pitch> pitchs){
    return pitchs.map((pitch){
      return Offset(pitch.location.dx, pitch.location.dy);
    }).toList();
  }

  Color getColorForDensity(double intensity){
    // final colors = gradientColors;
    // final ranges = intensityRanges;

    return Colors.transparent;

  }


  @override
  void paint(Canvas canvas, Size size) {
    print('Painting heatmap');
    List<Offset> points = getLocs(pitches);
    final double maxDensity = points.isEmpty ? 10 : points.length % 10 != 0 || points.length < 10 ? points.length % 10 : points.length / 10;
    final binWidth = size.width / gridCols;
    final binHeight = size.height / gridRows;

    final binDensities = List.generate(gridCols * gridRows, (_) => 0.0);

    for(final point in points){
      final centerX = point.dx;
      final centerY = point.dy;

      for(int row = 0; row < gridRows; row++){
        for(int col = 0; col < gridCols; col++){
          final binIndex = row * gridCols + col;

          final binCenterX = col * binWidth + binWidth / 2;
          final binCenterY = row * binHeight + binHeight / 2;

          final distance = Offset(binCenterX - centerX, binCenterY - centerY).distance;

          final intensity = calculateIntensity(distance);

          binDensities[binIndex] += intensity;

        }
      }
    }

    for(int row = 0; row < gridRows; row++){
      for(int col = 0; col < gridCols; col++){
        final binIndex = row * gridCols + col;
        final density = binDensities[binIndex];

        final color = lerpColors(Colors.blue, Colors.red, density / maxDensity);

        final left = col * binWidth;
        final top = row * binHeight;
        final right = left + binWidth;
        final bottom = top + binHeight;

        final rect = Rect.fromLTRB(left, top, right, bottom);

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, paint);
      }
    }

  }

  double calculateIntensity(double distance){
    const sigma = 10.0;
    // return 1.0 * (1.0 / (2.0 * pi * sigma * sigma)) * exp(-distance * distance / (2.0 * sigma * sigma));
    final intensity = exp(-distance * distance / (2.0 * sigma * sigma));
    return intensity * 8;
  }

  Color lerpColors(Color a, Color b, double t){
    return Color.lerp(a, b, t)!.withAlpha(150);
  }
    // @override
    // bool shouldRepaint(covariant CustomPainter oldDelegate){
    //   return true;
    // }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
      final oldData = (oldDelegate as paintHeatmap).pitches;
      final newData = pitches;

      // Only repaint if the data has changed.
      return oldData != newData;
    }
  }