// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:touchable/touchable.dart';
import 'package:my_app/eCharts.dart';

class paintPitch extends CustomPainter{
  List<Pitch> pitches;
  BuildContext context;
  String mode;
  paintPitch(this.pitches, this.context, this.mode);
  

  @override
  void paint(Canvas canvas, Size size){
    Canvas myCanvas = canvas;
        
    //if(mode == "Charting"){
      
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

    //}

  
    } /*else {
      
      TouchyCanvas myCanvas =  TouchyCanvas(context, canvas);
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
          myCanvas.drawRect(fb, paint, onTapDown: (details) => {_pitchInsight(pitch)});
        }

        //Curveball Shape
        if(pitch.type == "CB"){
          var cb = Path();
          cb.moveTo(pitch.location.dx, pitch.location.dy - 6);
          cb.lineTo(pitch.location.dx + 7.5, pitch.location.dy + 10);
          cb.lineTo(pitch.location.dx - 7.5, pitch.location.dy + 10);
          cb.lineTo(pitch.location.dx, pitch.location.dy - 7);
          myCanvas.drawPath(cb, paint, onTapDown: (details) => {_pitchInsight(pitch)});
          
        }

        //Change Up Shape
        if(pitch.type == "CH"){
          myCanvas.drawCircle(pitch.location, 7.5, paint, onTapDown: (details) => {_pitchInsight(pitch)});
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
          myCanvas.drawPath(sl, paint, onTapDown: (details) => {_pitchInsight(pitch)},
          );
        }

      }
      }*/
    }


  @override
  bool shouldRepaint(paintPitch oldDelegate) => true;
    
}