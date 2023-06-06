// ignore_for_file: prefer_initializing_formals, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Pitch{
  String type = "";
  int speed = 0;
  bool strike = false;
  bool swing = false;
  bool hit = false;
  bool k_looking = false;
  bool k_swinging = false;
  bool hbp = false;
  bool bb = false;
  Offset location = Offset.zero;
  bool in_zone = false;
  bool foul = false;
  bool bip = false;
  Tuple2<int, int> oldCount = Tuple2<int,int>(0,0);
  int strikes = 0;
  int balls = 0;
  Offset ar = const Offset(0, 0);
  Offset ar2 = const Offset(0, 0);

  Pitch(this.type, this.speed, this.strike, this.swing, this.hit, this.k_looking, this.k_swinging, this.hbp,
        this.bb, this.in_zone, this.foul, this.bip, this.location, this.oldCount);

  cBalls(){
    return oldCount.item1;
  }

  cStrikes(){
    return oldCount.item2;
  }

  getArea(){
    if(type == "FB"){
      ar = Offset(location.dx + 6, location.dy + 6);
      ar2 = Offset(location.dx - 6, location.dy - 6);
    } else if (type == "CB"){
      ar = Offset(location.dx + 4, location.dy + 4);
      ar2 = Offset(location.dx - 4, location.dy - 4);
    } else if (type == "CH"){
      ar = Offset(location.dx + 4, location.dy + 4);
      ar2 = Offset(location.dx - 4, location.dy - 4);
    }else if(type == 'SL'){
      ar = Offset(location.dx + 4, location.dy + 3);
      ar2 = Offset(location.dx - 4, location.dy - 3);
    }

    Rect area = Rect.fromPoints(ar, ar2);
    return(area);
  }

  factory Pitch.fromMap(Map <String, dynamic> pdata){
    return Pitch(
      pdata['type'],
      pdata['spd'],
      pdata['strike'],
      pdata['swing'],
      pdata['hit'],
      pdata['K'],
      pdata['ꓘ'],
      pdata['hbp'],
      pdata['bb'],
      pdata['in_zone'],
      pdata['foul'],
      pdata['bip'],
      Offset(pdata['loc_x'], pdata['loc_y']),
      Tuple2(pdata['oldCountBalls'], pdata['oldCountStrikes']),
    );
  }

}