import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/DellySkelly.dart';
import 'package:my_app/eCharts.dart';
import 'package:my_app/Baseball_Pieces/Hit.dart';
import 'dart:ui';
import 'package:my_app/linePainter.dart';
import 'package:dashed_line/dashed_line.dart';

String rslt = ' ';
String pathtype = ' ';

class HittingWidget extends StatefulWidget {
  @override
  _HittingWidgetState createState() => _HittingWidgetState();
}

class _HittingWidgetState extends State<HittingWidget> {
  Offset dots = const Offset(250.5, 305);
  Offset startPoint = const Offset(250.5, 305); // 255, 305
  Size dellySkellyH = const Size(500, 50);
  List<bool> isPath = List.filled(BIPpaths.length, false);


  @override
  Widget build(BuildContext context) {
      return AlertDialog(
        title: const Text('Ball In Play Chart'),
        content: SizedBox(
          height: 600,
          width: 500,
          child: Stack(
            children: [
              SizedBox(
                height: 400,
                width: 500,
                child: GestureDetector(
                  onTapUp: (TapUpDetails details) {
                    setState(() {
                      Offset tappedPosition = details.localPosition;
                      dots = tappedPosition;
                    });
                  },
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
                          pathtype == 'Ground Ball' ? linePainter(dots, startPoint) :
                          pathtype == 'Line Drive' ? DrawingPainter([dots], startPoint) :
                          linePainter(dots, startPoint)
                        ),
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
              CustomSingleChildLayout(
                delegate: DellySkelly(
                  widgetSize: dellySkellyH,
                  height: 100,
                  width: dellySkellyH.width,
                  off1: 0,
                  off2: 400,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      direction: Axis.horizontal,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.red[700],
                      selectedColor: Colors.white,
                      fillColor: Colors.red[200],
                      color: Colors.red[400],
                      constraints: const BoxConstraints(
                        minHeight: 50.0,
                        minWidth: 100.0,
                      ),
                      
                      onPressed: (_) {
                        setState(() {
                        for (int i = 0; i < isPath.length; i++) {
                          isPath[i] = i == _ && !isPath[_];
                          pathtype = (BIPpaths[_] as Text).data ?? '';
                        }
                        });
                      },
                      isSelected: isPath,
                      children: BIPpaths,
                    ),
                  ],
                ),
              ),
              CustomSingleChildLayout(
                delegate: DellySkelly(
                  widgetSize: dellySkellyH,
                  height: 100,
                  width: dellySkellyH.width,
                  off1: 0,
                  off2: 500,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Result: '),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton<String>(
                      value: rslt,
                      onChanged: (String? newValue) {
                        setState(() {
                          rslt = newValue!;
                        });
                      },
                      items: BIPResults
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                    ),
                  ),      
                    ElevatedButton(onPressed: () {
                                      Hit hit = Hit(pathtype, dots, rslt);
                                      rslt = ' ';
                                      pathtype = ' ';
                                      Navigator.pop(context, hit);
                                      }, 
                                      child: const Text('Confirm'))
                ],)
              ),
            ],
          ),
        ),
    );
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