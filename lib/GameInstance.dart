// ignore_for_file: unused_import, file_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/Baseball_Pieces/Player.dart';

class GameInstance {

  List<Pitch> pitches = [];
  String pitcher = ' ';
  String team = ' ';
  String opponent = ' ';
  String mm = ' ';
  String dd = ' ';
  Key id = UniqueKey();
  dynamic gNum;

  GameInstance(this.pitches, this.pitcher, this.team, this.opponent, this.mm, this.dd, this.gNum);

  factory GameInstance.fromMap(Map <String, dynamic> gdata){
    return GameInstance(
      (gdata['pitches'] as List<dynamic>).cast<Pitch>(),
      gdata['pitcher'],
      gdata['team'],
      gdata['opponent'],
      gdata['mm'],
      gdata['dd'],
      gdata['gNum'],
    );
  }

  String getDisplayText(){
    return '$team $mm/$dd $gNum';
  }

  Map<String, dynamic> toJson() {
    return {
      'pitches': pitches.map((pitch) => pitch.toJson()).toList(),
      'pitcher': pitcher,
      'team': team,
      'opponent': opponent,
      'mm': mm,
      'dd': dd,
      'gNum': gNum,
    };
  }

  factory GameInstance.fromJson(Map<String, dynamic> json){
    GameInstance game = GameInstance([],"","","","","","");
    List<dynamic> t = json['pitches'];
    game.pitches = t.map((pitch) => Pitch.fromJson(pitch)).toList().cast<Pitch>();
    game.pitcher = json['pitcher'];
    game.team = json['team'];
    game.opponent = json['opponent'];
    game.mm = json['mm'];
    game.dd = json['dd'];
    game.gNum = json['gNum'];
    return game;
  }
}