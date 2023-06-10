// ignore_for_file: file_names, unused_import, unnecessary_this, prefer_initializing_formals, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/GameInstance.dart';
import 'package:firebase_database/firebase_database.dart';


class Player{
  String name;
  List<Pitch> unsaved_pitches = [];
  List<GameInstance> games = [];

  List<Pitch> total_staple = [];
  List<Pitch> total_dynamic = [];
  List<Pitch> displayPitches = [];

  String id = "";

  //Input only being pitcher name and pitch?
  Player(this.name);

  void addGame(GameInstance game){
      games.add(game);
  }

  void setId(String id){
    this.id = id;
  }

  Map<String, dynamic> toJson(){
    return {
      'name' : this.name,
      'id' : this.id,
      'unsaved_pitches' : this.unsaved_pitches.map((pitch) => pitch.toJson()).toList(),
      'games' : this.games.map((game) => game.toJson()).toList(),
      'total_staple': this.total_staple.map((pitch) => pitch.toJson()).toList(),
      'total_dynamic': this.total_dynamic.map((pitch) => pitch.toJson()).toList(),
      'displayPitches': this.displayPitches.map((pitch) => pitch.toJson()).toList(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> playerData) {
    return Player(
      playerData['pitcher'],
    )..games = List<GameInstance>.from(playerData['games'].map((gameData) => GameInstance.fromMap(gameData)));
  }

  List<Pitch> convertToPitch(List<dynamic> pitches){
    List<Pitch> finale = [];
    for(var item in pitches){
      Pitch newPitch = Pitch.fromJson(item);
      finale.add(newPitch);
    }
    return finale;
  }

  factory Player.fromJson(Map<String, dynamic> pData){
    Player pitcher = Player(pData['name']);
    pitcher.name = pData['name'];
    pitcher.id = pData['id'];
    pitcher.unsaved_pitches = pData['unsaved_pitches'];
    pitcher.games = pData['games'];
    pitcher.total_staple = pData['total_staple'];
    pitcher.displayPitches = pData['displayPitches'];
    return(pitcher);
  }
}

