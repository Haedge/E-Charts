// ignore_for_file: file_names, unused_import, unnecessary_this, prefer_initializing_formals, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/GameInstance.dart';
// import 'package:firebase_database/firebase_database.dart';


class Player{
  String name;
  List<Pitch> unsaved_pitches = [];
  List<GameInstance> games = [];

  List<Pitch> total_staple = [];
  List<Pitch> total_dynamic = [];
  List<Pitch> displayPitches = [];

  //DatabaseReference _id = "" as DatabaseReference;

  //Input only being pitcher name and pitch?
  Player(this.name);

  void addGame(GameInstance game){
      games.add(game);
  }

  // void setId(DatabaseReference id){
  //   this._id = id;
  // }

  Map<String, dynamic> toJson(){
    return {
      'pitcher' : this.name,
      'games' : this.games,
    };
  }

}

