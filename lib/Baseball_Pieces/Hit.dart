import 'dart:convert';

import 'package:flutter/material.dart';


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

  Map<String,dynamic> toFlite(){
    return{
      'ball_path': ball_path,
      'loc': jsonEncode({'dx': location.dx, 'dy': location.dy}),
      'result': result
    };
  }

  factory Hit.fromFlite(Map<String, dynamic> map){
    Map<String,dynamic> locInfo = jsonDecode(map['loc']);
    return Hit(
      map['ball_path'],
      Offset(double.parse(locInfo['dx']), double.parse(locInfo['dy'])),
      map['result']
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hit &&
          ball_path == other.ball_path &&
          location == other.location &&
          result == other.result;

  @override
  int get hashCode =>
      ball_path.hashCode ^ location.hashCode ^ result.hashCode;

}