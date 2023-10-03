// ignore_for_file: camel_case_types, file_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/eCharts.dart';

class paintHeatmap extends CustomPainter{
  List<Pitch> pitches;
  BuildContext context;
  String mode;
  final int divisions;
  final List<Color> colors;
    
  paintHeatmap(this.pitches, this.context, this.mode,
              {
               this.divisions = 100, 
               this.colors = const [Colors.white, Colors.green]
              }
  );

  List<Offset> getLocs(List<Pitch> pitchs){
    return pitchs.map((pitch){
      return Offset(pitch.location.dx, pitch.location.dy);
    }).toList();
  }

  Color? getColor(List<Color> colors, double density){
    if (colors == null || colors.isEmpty) {return Colors.transparent;}
    if (density < 0) {density = 0;} else if(density > 1){density = 1;}

    final double index = density * (colors.length - 1);
    final int lowerIndex = index.floor();
    final int upperIndex = index.ceil();

    if(lowerIndex == upperIndex){
      return colors[lowerIndex].withAlpha(128);
    } else {
      final double fraction = index - lowerIndex;
      final Color lowerColor = colors[lowerIndex];
      final Color upperColor = colors[upperIndex];

      return Color.lerp(lowerColor, upperColor, fraction)!.withAlpha(128);
    }

  }
    


  @override
  void paint(Canvas canvas, Size size) {


    const int maxDensity = 20;
    const List<Color> intensityColors = [
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red
    ];

    List<Offset> points = getLocs(pitches);



      for (final point in points){
        final density = calculateDensity(point, points, size);

        final colorIndex = (density / maxDensity * (intensityColors.length - 1)).round();
        final color = intensityColors[colorIndex];

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(point, 7.5, paint);

      }
    }

  double calculateDensity(Offset point, List<Offset> allPoints, Size size){
    const radius = 50.0;
    final nearbyPoints = allPoints.where((p) => (p - point).distanceSquared <= radius * radius).toList();
    return nearbyPoints.length.toDouble();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    return true;
  }
}