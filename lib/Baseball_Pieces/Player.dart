// ignore_for_file: file_names, unused_import, unnecessary_this, prefer_initializing_formals, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/GameInstance.dart';
// import 'package:firebase_database/firebase_database.dart';


class Player{
  String name;
  List<Pitch> total_pitches = [];
  List<Pitch> unsaved_pitches = [];
  List<Pitch> pitch_locations = [];
  List<Pitch> pitches_requested = [];
  List<GameInstance> games = [];
  //DatabaseReference _id = "" as DatabaseReference;

  //Input only being pitcher name and pitch?
  Player(this.name);

  void addGame(GameInstance game){
    GameInstance new_game = GameInstance(game.pitches, game.pitcher, game.team, game.mm, game.dd);
    games.add(game);
    total_pitches.addAll(new_game.pitches.toList());
  }

  getCertPitches(String type){
    pitches_requested = [];
    /*
    if(games.isNotEmpty){
      for(var game in games){
        for(var pitch in game.pitches){
          if(pitch.type == type){
            certPitches.add(pitch);
          }
        }
      }
    }
    */
    for(var pitch in total_pitches){
      if(pitch.type == type){
        pitches_requested.add(pitch);
      }
    }
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

