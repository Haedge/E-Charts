// ignore_for_file: prefer_initializing_formals, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'Hit.dart';
import 'dart:convert';

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
  Tuple2<int, int> oldCount = const Tuple2<int,int>(0,0);
  int strikes = 0;
  int balls = 0;
  Offset ar = const Offset(0, 0);
  Offset ar2 = const Offset(0, 0);
  dynamic contact = false;
  Hit hdesc = Hit("", const Offset(0, 0), "");
  Hit def_hdesc = Hit("", const Offset(0, 0), "");


  Pitch(this.type, this.speed, this.strike, this.swing, this.hit, this.k_looking, this.k_swinging, this.hbp,
        this.bb, this.in_zone, this.foul, this.bip, this.location, this.oldCount, this.hdesc);

  cBalls(){
    return oldCount.item1;
  }

  cStrikes(){
    return oldCount.item2;
  }

  List<Pitch> convertToPitch(List<dynamic> pitches){
    List<Pitch> finale = [];
    for(var item in pitches){
      Pitch newPitch = Pitch.fromJson(item);
      finale.add(newPitch);
    }
    return finale;
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
      pdata['ꓘ'],
      pdata['K'],
      pdata['hbp'],
      pdata['bb'],
      pdata['in_zone'],
      pdata['foul'],
      pdata['bip'],
      Offset(pdata['loc_x'], pdata['loc_y']),
      Tuple2(pdata['oldCountBalls'], pdata['oldCountStrikes']),
      pdata['hdesc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'spd': speed,
      'strike': strike,
      'swing': swing,
      'hit': hit,
      'ꓘ': k_looking,
      'K': k_swinging,
      'hbp': hbp,
      'bb': bb,
      'loc_x': location.dx,
      'loc_y': location.dy,
      'in_zone': in_zone,
      'foul': foul,
      'bip': bip,
      'oldCountBalls': oldCount.item1,
      'oldCountStrikes': oldCount.item2,
      'hdesc': hdesc.toJson(),
    };
  }

  factory Pitch.fromJson(Map<String, dynamic> json){
    Hit def_hdesc = Hit("", const Offset(0, 0), "");
    return Pitch(
      json['type'],
      json['spd'],
      json['strike'],
      json['swing'],
      json['hit'],
      json['ꓘ'],
      json['K'],
      json['hbp'],
      json['bb'],
      json['in_zone'],
      json['foul'],
      json['bip'],
      Offset(json['loc_x'], json['loc_y']),
      Tuple2(json['oldCountBalls'], json['oldCountStrikes']),
      json['hdesc'] != null ? Hit.fromJson(json['hdesc']) : def_hdesc,
    );
  }

  Map<String, dynamic> toFlite(){
    return {
      'type': type,
      'spd': speed,
      'strike': strike ? 1 : 0,
      'swing': swing ? 1 : 0,
      'hit': hit ? 1 : 0,
      'k_looking': k_looking ? 1 : 0,
      'k_swinging': k_swinging ? 1 : 0,
      'hbp': hbp ? 1 : 0,
      'bb': bb ? 1 : 0,
      'in_zone': in_zone ? 1 : 0,
      'foul': foul ? 1 : 0,
      'bip': bip ? 1 : 0,
      'loc': jsonEncode({'dx': location.dx, 'dy': location.dy}),
      'old_count': jsonEncode({'balls': oldCount.item1, 'strikes': oldCount.item2}),
      'hdesc': hdesc.toFlite()
    };
    }
  
  factory Pitch.fromFlite(Map<String, dynamic> info){
    Map<String, dynamic> loc_info = jsonDecode(info['loc']);
    Map<String, dynamic> oldCount_info = jsonDecode(info['old_count']);
    return Pitch(
      info['type'], info['spd'],
      info['strike'] == 1, info['swing'] == 1, info['hit'] == 1,
      info['k_looking'] == 1, info['k_swinging'] == 1, info['hbp'] == 1,
      info['bb'] == 1, info['in_zone'] == 1, info['foul'] == 1,
      info['bip'] == 1,
      Offset(double.parse(loc_info['dx']), double.parse(loc_info['dy'])),
      Tuple2(int.parse(oldCount_info['balls']), int.parse(oldCount_info['strikes'])),
      Hit.fromFlite(jsonDecode(info['hdesc']))
    );
  }

    // Pitch(this.type, this.speed, this.strike, this.swing, this.hit, this.k_looking, this.k_swinging, this.hbp,
    //     this.bb, this.in_zone, this.foul, this.bip, this.location, this.oldCount, this.hdesc);

}