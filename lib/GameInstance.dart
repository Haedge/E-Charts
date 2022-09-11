// ignore_for_file: unused_import, file_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/Baseball_Pieces/Player.dart';

class GameInstance {

  List<Pitch> pitches = [];
  Player pitcher;
  String team;
  String day;
  String month;
  int game_num;

  GameInstance(this.pitches, this.pitcher, this.team, this.game_num, this.month, this.day);
  
}