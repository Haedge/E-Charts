// ignore_for_file: file_names, unused_import, unnecessary_this, prefer_initializing_formals, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/GameInstance.dart';

class Player{
  String name = "";
  Map games = {};
  List<Pitch> total_pitches = [];

  //Input only being pitcher name and pitch?
  Player(String name, Map games, List<Pitch> total_pitches){
    this.name = name;
    this.games = games;
    this.total_pitches = total_pitches;
  }

  void addGame(Player pitcher, GameInstance game){
  pitcher.games[game.team] = game.pitches;
  pitcher.total_pitches.addAll(game.pitches);
}



}

