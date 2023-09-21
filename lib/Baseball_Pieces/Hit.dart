// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/GameInstance.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tuple/tuple.dart';


class Hit {
  String ball_path;
  Offset location;
  String result;

  Hit(this.ball_path, this.location, this.result);



  factory Hit.fromJson(Map <String, dynamic> data){
    return Hit(
      data['ball_path'],
      Offset(data['loc_x'], data['loc_y']),
      data['result']
      );
  }

  Map<String, dynamic> toJson(){
    return {
      'ball_path': ball_path,
      'loc_x': location.dx,
      'loc_y': location.dy,
      'result': result
    };
  }

}