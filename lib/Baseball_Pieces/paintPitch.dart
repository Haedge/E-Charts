// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';

class paintPitch extends CustomPainter{
  List<Pitch> pitches;
  paintPitch(this.pitches);
  

  @override
  void paint(Canvas canvas, Size size){
      

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
        canvas.drawRect(fb, paint);
      }

      //Curveball Shape
      if(pitch.type == "CB"){
        var cb = Path();
        cb.moveTo(pitch.location.dx, pitch.location.dy - 6);
        cb.lineTo(pitch.location.dx + 7.5, pitch.location.dy + 10);
        cb.lineTo(pitch.location.dx - 7.5, pitch.location.dy + 10);
        cb.lineTo(pitch.location.dx, pitch.location.dy - 7);
        canvas.drawPath(cb, paint);
      }

      //Change Up Shape
      if(pitch.type == "CH"){
        canvas.drawCircle(pitch.location, 7.5, paint);
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
        canvas.drawPath(sl, paint);
      }

    }
  }
  @override
  bool shouldRepaint(paintPitch oldDelegate) => true;
}