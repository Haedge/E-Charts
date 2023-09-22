import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/DellySkelly.dart';
import 'package:my_app/eCharts.dart';
import 'package:my_app/Baseball_Pieces/Hit.dart';
import 'dart:ui';
import 'package:dashed_line/dashed_line.dart';
import 'dart:math' as math;

class sprayWidget extends StatefulWidget {
  List<Pitch> locs;

  sprayWidget({required this.locs});

  @override
  _sprayWidgetState createState() => _sprayWidgetState();
}

class _sprayWidgetState extends State<sprayWidget>{
  @override
  Widget build(BuildContext context) {
    
    Offset startPoint = const Offset(186, 227);
    Size dellySkellyH = const Size(500, 50);
    Text info = widget.locs.length == 1 ? Text('${widget.locs[0].hdesc.ball_path}, ${widget.locs[0].hdesc.result}') : 
                const Text('Spray Chart');

      return AlertDialog(
        content: SizedBox(
          height: 300,
          width: 375,
          child: Stack(
            children: [
              info,
              SizedBox(
                height: 300,
                width: 375,
                child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Image.asset('assets/images/baseball_field.png'),
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: (
                          MasterPainter(widget.locs, startPoint)
                        ),
                        child: Container(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    );
  }
}

class MasterPainter extends CustomPainter {
  final List<Pitch> pitches;
  final Offset startPoint;

  MasterPainter(this.pitches, this.startPoint);

  @override
  void paint(Canvas canvas, Size size){
    for(Pitch pitch in pitches){
      if(pitch.hdesc != null){
          var desc = pitch.hdesc;
          double adjlocx = desc.location.dx * (300 / 400);
          double adjlocy = desc.location.dy * (300 / 400);
        if(pitch.hdesc.ball_path == 'Line Drive'){
          List<Offset> plotting = [startPoint];
          Paint dotPaint = Paint()
            ..color = Colors.black
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;

          Paint linePaint = Paint()
            ..color = Colors.blue
            ..strokeWidth = 2;
          
          // TODO: Possible change here
          plotting.add(Offset(adjlocx, adjlocy));

          canvas.drawPoints(PointMode.points, plotting, dotPaint);

          canvas.drawLine(startPoint, plotting[1], linePaint);
        } else {
          // Draw the dotted line
          final path = Path();
          path.moveTo(startPoint.dx, startPoint.dy);
          path.lineTo(adjlocx, adjlocy);
          
          Paint dotPaint = Paint()
            ..color = Colors.black
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;

          final Paint paint = Paint()
            ..color = desc.ball_path == 'Ground Ball' ? const Color.fromARGB(227, 0, 0, 0): Colors.red
            ..strokeCap = StrokeCap.square
            ..strokeWidth = 1;

          const dashWidth = 5; 
          const dashSpace = 5; 
          final distance = math.sqrt(math.pow(adjlocx - startPoint.dx, 2) + math.pow(adjlocy - startPoint.dy, 2));
          final dotsCount = (distance / (dashWidth + dashSpace)).floor();

          

          for (int i = 0; i < dotsCount; i++) {
            final dotOffset = i / dotsCount;
            final dotPosition = dotOffset * distance;
            final dotPath = Path();
            dotPath.moveTo(startPoint.dx, startPoint.dy);
            dotPath.lineTo(
              startPoint.dx + (adjlocx - startPoint.dx) * dotOffset + dotPosition,
              startPoint.dy + (adjlocy - startPoint.dy) * dotOffset + dotPosition,
            );
            
            canvas.drawPoints(PointMode.points, [startPoint, Offset(adjlocx, adjlocy)], dotPaint);
            drawDashedLine(canvas: canvas, p1: startPoint, p2: Offset(adjlocx, adjlocy), pattern:
            (desc.ball_path == 'Ground Ball' ? [3, 10] : [20,10]), paint: paint);
          }
              }
            }
          }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    return true;
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

class DrawingPainter extends CustomPainter {
  final List<Offset> dots;
  final Offset startPoint;

  late List<Offset> plotting = [startPoint];
  

  DrawingPainter(this.dots, this.startPoint);

  @override
  void paint(Canvas canvas, Size size) {
    Paint dotPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    
    plotting.addAll(dots);

    canvas.drawPoints(PointMode.points, plotting, dotPaint);

    if (dots.isNotEmpty) {
      canvas.drawLine(startPoint, plotting[1], linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}