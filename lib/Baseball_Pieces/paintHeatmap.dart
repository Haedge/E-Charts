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

  List<Offset> getLocs(Size size, List<Pitch> pitchs){
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
    var binPaint = Paint()..style = PaintingStyle.fill;
    var binWidth = size.width / divisions;
    var binHeight = size.height / divisions;
    Canvas myCanvas = canvas;

    // Clear the canvas
    myCanvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.transparent);

    var bins = List<List<int>>.generate(
      divisions, (i) => List<int>.generate(divisions, (j) => 0)
    );

    var maxBinCount = 0;

    getLocs(size, pitches).forEach((loc) {
      var xBin = min((loc.dx / binWidth).floor(), divisions - 1);
      var yBin = min((loc.dy / binHeight).floor(), divisions - 1);

      bins[xBin][yBin]++;

      maxBinCount =
        bins[xBin][yBin] > maxBinCount ? bins[xBin][yBin] : maxBinCount;

    });

    bins.asMap().forEach((rowIndex, row) {
      row.asMap().forEach((colIndex, col) {
        var left = binWidth * rowIndex;
        var top = binHeight * colIndex;
        var right = binWidth * (rowIndex + 1);
        var bottom = binHeight * (colIndex + 1);

        var color = getColor(colors, col / maxBinCount);

        canvas.drawRRect(RRect.fromLTRBR(left, top, right, bottom, Radius.zero),
        binPaint..color = color!);

      });
    });

  }

  
  
  
  @override
  bool shouldRepaint(paintHeatmap oldDelegate) => true;
}