// ignore_for_file: file_names, unused_import, unnecessary_this, prefer_initializing_formals, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/GameInstance.dart';

String columnPitcher = "Pitcher";
String columnGames = "Games";
String columnTotalPitches = "Total Pitches";


class Player{
  String name;
  List<Pitch>? total_pitches;
  List<GameInstance>? games;

  //Input only being pitcher name and pitch?
  Player({required this.name});

  void addGame(Player pitcher, GameInstance game){
    pitcher.games!.add(game);
    pitcher.total_pitches!.addAll(game.pitches);
  }

  // Pitcher[name] = {games, total pitches}
/*
  Map<String, List<GameInstance>> toMap(){
    var map = <String, List<GameInstance>>{
      columnPitcher: name,
      columnGames: games.isEmpty ? [] : games,
    };
    return map;
  }

  Player.fromMap(Map<String, List<GameInstance>> map){

  }
  */


}

