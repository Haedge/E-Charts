// ignore_for_file: camel_case_types, file_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/eCharts.dart';

class paintHeatmap extends CustomPainter{
  List<Pitch> pitches;
  BuildContext context;
  final int gridCols;
  final int gridRows;
    
  paintHeatmap(this.pitches, this.context,
              {
               this.gridCols = 25,
               this.gridRows = 25,
              }
  );

  List<Offset> getLocs(List<Pitch> pitchs){
    return pitchs.map((pitch){
      return Offset(pitch.location.dx, pitch.location.dy);
    }).toList();
  }


  @override
  void paint(Canvas canvas, Size size) {
    print('Painting heatmap');
    const int maxDensity = 2;
    final binWidth = size.width / gridCols;
    final binHeight = size.height / gridRows;

    final binDensities = List.generate(gridCols * gridRows, (_) => 0);

    List<Offset> points = getLocs(pitches);

    for(final point in points){
      final col = (point.dx / size.width * gridCols).floor();
      final row = (point.dy / size.height * gridRows).floor();
      final binIndex = row * gridCols + col;


      binDensities[binIndex]++;
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