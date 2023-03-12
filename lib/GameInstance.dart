// ignore_for_file: unused_import, file_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/Baseball_Pieces/Player.dart';

class GameInstance {

  List<Pitch> pitches = [];
  Player pitcher;
  String team;
  String mm;
  String dd;

  GameInstance(this.pitches, this.pitcher, this.team, this.mm, this.dd);
  
}