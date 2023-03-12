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

  Pitch(String type, int speed, bool strike, bool swing, bool hit, bool k_looking, bool k_swinging, bool hbp,
        bool bb, Offset location, bool in_zone, Tuple2<int,int> oldCount, bool foul, bool bip){
    this.type = type;
    this.speed = speed;
    this.strike = strike;
    this.swing = swing;
    this.hit = hit;
    this.k_looking = k_looking;
    this.k_swinging = k_swinging;
    this.hbp = hbp;
    this.bb = bb;
    this.location = location;
    this.in_zone = in_zone;
    this.oldCount = oldCount;
    this.foul = foul;
    this.bip = bip;
  }

  _cBalls(){
    return oldCount.item1;
  }

  _cStrikes(){
    return oldCount.item2;
  }


}