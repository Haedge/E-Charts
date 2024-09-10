// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
// import 'package:my_app/eCharts.dart';

class paintPitch extends CustomPainter{
  List<Pitch> pitches;
  BuildContext context;
  String mode;
  paintPitch(this.pitches, this.context, this.mode);
  

  @override
  void paint(Canvas canvas, Size size){
    print('Paint Pitch');
    Canvas myCanvas = canvas;

    // Clear the canvas
    myCanvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.transparent);

      
    for(Pitch pitch in pitches){

      Color? pitchc = Colors.black;

      if(pitch.in_zone){
        pitchc = Colors.redAccent;
      } else {
        pitchc = Colors.blue[600];
      }



      Paint paint = Paint()
      ..color = pitchc!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;


      //If a swing, then fill the shape
      if(pitch.swing){
          paint.style = PaintingStyle.fill;
        }

      // Fastball Shape
      if(pitch.type == "FB"){
        Rect fb = Rect.fromCenter(center: pitch.location, width: 12, height: 12);
        myCanvas.drawRect(fb, paint);
      }

      //Curveball Shape
      if(pitch.type == "CB"){
        var cb = Path();
        cb.moveTo(pitch.location.dx, pitch.location.dy - 6);
        cb.lineTo(pitch.location.dx + 7.5, pitch.location.dy + 10);
        cb.lineTo(pitch.location.dx - 7.5, pitch.location.dy + 10);
        cb.lineTo(pitch.location.dx, pitch.location.dy - 7);
        myCanvas.drawPath(cb, paint);
        
      }

      //Change Up Shape
      if(pitch.type == "CH"){
        myCanvas.drawCircle(pitch.location, 7.5, paint);
      }

      //Slider Shape
      if(pitch.type == "SL"){
        var sl = Path();
        sl.moveTo(pitch.location.dx - 6, pitch.location.dy - 6);
        sl.lineTo(pitch.location.dx + 6, pitch.location.dy - 6);
        sl.lineTo(pitch.location.dx + 9, pitch.location.dy);
        sl.lineTo(pitch.location.dx + 6, pitch.location.dy + 6);
        sl.lineTo(pitch.location.dx - 6, pitch.location.dy + 6);
        sl.lineTo(pitch.location.dx - 9, pitch.location.dy);
        sl.lineTo(pitch.location.dx - 6, pitch.location.dy - 7);
        myCanvas.drawPath(sl, paint);
      }
    } 
  }


  // @override
  // bool shouldRepaint(paintPitch oldDelegate) => true;

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
      final oldData = (oldDelegate as paintPitch).pitches;
      final newData = pitches;

      // Only repaint if the data has changed.
      return oldData != newData;
    }
    
}