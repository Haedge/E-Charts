// ignore_for_file: unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable, constant_identifier_names, file_names

import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/rendering.dart';
// import 'package:my_app/database.dart';
// import 'package:my_app/database_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'Baseball_Pieces/PitchWidget.dart';
import 'Baseball_Pieces/Player.dart';
import 'Baseball_Pieces/Pitch.dart';
import 'Baseball_Pieces/Hit.dart';
// import 'Baseball_Pieces/paintPitch.dart';
import 'Baseball_Pieces/sprayWidget.dart';
import 'HomePage.dart';
import 'GameInstance.dart';
import 'package:multiselect/multiselect.dart';
import 'package:tuple/tuple.dart';
// import 'package:touchable/touchable.dart';
import 'DellySkelly.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'Baseball_Pieces/HittingWidget.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



String current_mode = "Charting";

final FirebaseFirestore firestore = FirebaseFirestore.instance;

const PTypes = <Widget>[
  Text('Fastball'),
  Text('Curveball'),
  Text('Changeup'),
  Text('Slider')
];

const PActions = <Widget>[
  Text('Swing'),
  Text('Foul'),
  Text('Hit'),
  Text('BB'),
  Text('HBP'),
  Text('K'),
  Text('ꓘ'),
  Text('BIP')
];

const BIPpaths = <Widget> [
  Text('Ground Ball'),
  Text('Line Drive'),
  Text('Fly Ball'),
];

const BIPResults = [
  ' ',
  'Out',
  'Single',
  'Double',
  'Triple',
  'HR',
  'FC',
];

const List<String> PActionsList = ['Swing', 'Foul', 'Hit', 'BB', 'HBP', 'K', 'ꓘ', 'BIP'];



class eCharts extends State<HomePage> {
  List<Pitch> _currentPitches = [];
  List<Offset> _cPitchLocations = [];
  List<Pitch> _displayPitches = [];
  List<Offset> _displayLocations = [];
  int _pitch_count = 0;
  String month = DateTime.now().month.toString();
  String day = DateTime.now().day.toString();
  String year = DateTime.now().year.toString();

  final List<String> pitchChoices = ['FB', 'CH', 'CB', 'SL'];

  final Map<String, double> cExtras = {'numHBP' : 0, 'numHits' : 0, 'numKs' : 0,
                                      'strike_count' : 0, 'numWalks' : 0, 'strikeP' : 0,
                                      'pitch_count' : 0};



  Map<String, Map<String, double>> pitchStats = {
    'FB' : {'avg' : 0, 'min' : 0, 'max' : 0, 'StrikeP' : 0},
    'CH' : {'avg' : 0, 'min' : 0, 'max' : 0, 'StrikeP' : 0},
    'CB' : {'avg' : 0, 'min' : 0, 'max' : 0, 'StrikeP' : 0},
    'SL' : {'avg' : 0, 'min' : 0, 'max' : 0, 'StrikeP' : 0}
  };

  Map<String, int> countCounts = {
    'start' : 0, 'even' : 0,
    '1b0s' : 0, '0b1s' : 0,

    'stb' : 0, 'sts' : 0,
    '1btb' : 0, '1bts' : 0,
    '1stb' : 0, '1sts' : 0,

    '1b1sts' : 0, '1b1stb' : 0,

  };

  Map<String, double> countPercent = {
    'start2ball' : 0, 'start2strike' : 0,
    '1ball2ball' : 0, '1ball2strike' : 0,
    '1strike2ball' : 0, '1strike2strike' : 0,
    'even2ball' : 0, 'even2strike' : 0
  };

  List<dynamic> dropDownItems = [
    'FB', 'CB', 'CH', 'SL', 'Strike', 'Ball'
  ];




  Color? modeColor = Colors.black;
  Tuple2<int,int> current_count = const Tuple2<int,int> (0,0);
  
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  late List<String> _Pitchers = []; // 'Andrei Stoyanow', 'Bobby Fowler', 'Cade McWilliams', 'Connor Stack', 'David Blackburn',
                                  // 'Ethan Thomas', 'Gunner Hopkins', 'Hogan Ralston', 'Jack Hodgins', 'Jackson Corrigan', 'Jacob Wagner', 'John Henry Fowler', 
                                  // 'John Schaller', 'Johnny Miles', 'Kyle Poissoit', 'Miles Schluterman', 'Nathan Silva', 'Patrick Chastain', 
                                  // 'Ryan da best eva Torres', 'Teddy Olander', 'Tyler Meek', 'Aiden Leggit', 'Brax Waller', 'Bryson Bales', 'Caleb Ougel',
                                  // 'Chance Reed', 'Chase Nials', 'JD Nichols', 'Kyler Oathout', 'Matthew Mitchell', 'Miko Djuric', 'Nate Hirsh',
                                  // 'Nic Luna', 'Sam Collier', 'Trent Jordan', 'Tucker Isbell', 'William Kuebler', 'Wyatt Goodman', 'Zane Nolan',
                                  // 'Ian Guthrie', 'Test Pitcher'];
  late List<Player> _p_pitchers = [];
  
  List<GameInstance> _pitcherGamesG = [];
  List<String> _pitcherGamesS = ['FB', 'CB', 'CH', 'SL'];


  String _currentPitcher = " ";
  String _pitcherRemove = " ";
  TextEditingController _moText = TextEditingController();
  TextEditingController _dayText = TextEditingController();
  TextEditingController _yrText = TextEditingController();
  String _currentTeam = " ";
  final List<String> _Teams = [' ', 'Belhaven', 'Berry','BSC', 'CBC', 'Centre', 'Dallas', 'Depauw', 'Millsaps', 'Nebraska', 'Oglethorpe', 'Ozarks', 'Rhodes',
                                'St Thomas','Scrimmage','Sewanee', 'Bullpen', 'Fall WS', 'OBU', 'Wash U'];
  List<bool> isPType = List.filled(4, false);
  List<bool> isPAction = List.filled(8, false);

  List<Player> _pitchPlayer = [];
  List<String> selected = [];
  PitchWidget? pitchWidget;
  

  
  
  getGames(Player pitcher){
    return pitcher.games;
  }

  _printScreen(){
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await WidgetWrapper.fromKey(
        key: _printKey,
        pixelRatio: 1.0,
        );
      
      doc.addPage(pw.Page(
        pageFormat: format,
        build: (pw.Context context){
          return pw.Center(
            child: pw.Expanded(
              child: pw.Image(image),
            ),
          );
        }
      ));
      return doc.save();
    }
    );
  }

  _newCount(){
    current_count = const Tuple2<int,int> (0,0);
    setState(() {});
  }

  _reset(String pitcher){
    _pitchPlayer[_Pitchers.indexOf(pitcher)].total_dynamic = [];
    _pitchPlayer[_Pitchers.indexOf(pitcher)].unsaved_pitches = [];
    _currentPitcher = " ";
    _currentTeam = ' ';
    _cPitchLocations = [];

    for(String entry in pitchChoices){
      pitchStats[entry]!.forEach((key, value) => pitchStats[entry]![key] = 0);
    }

    cExtras.forEach((key, value) => cExtras[key] = 0);
    
    _calculateCountPerc([]);
    setState(() {});
    current_count = const Tuple2<int,int> (0,0);
  }

  _modeSwitch() async {
    Player p = getPitcher(_currentPitcher);
    final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(p.id);

    if(current_mode == "Charting"){
      current_mode = "Viewing";
      modeColor = Colors.redAccent;
      await playerRef.update({
        'displayPitches': p.total_staple.map((e) => e.toJson()),
      });
      selected = [];
      // print('Current pitch number CtV: ${_currentPitches.length}');
    } else {
      current_mode = "Charting";
      selected = [];
      // p.displayPitches = List.from(p.unsaved_pitches);
      await playerRef.update({
        'displayPitches': p.unsaved_pitches.map((e) => e.toJson()),
      });
      modeColor = Colors.blue;
      // print('Current pitch number VtC: ${_currentPitches.length}');
    }

    await playerRef.update({
      
    });

    setState(() {});
  }


  _createInstance(String pitcher, Map<String, dynamic> gdata) async {
    Player p_pitcher = getPitcher(pitcher);
    GameInstance game = GameInstance.fromMap(gdata);

    // pitcher.setId(savePitcher(pitcher));
    p_pitcher.addGame(game);
    p_pitcher.unsaved_pitches = [];
    p_pitcher.displayPitches = [];

    final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(p_pitcher.id);
    await playerRef.update({
      'unsaved_pitches': [],
      'displayPitches': [],
      'games' : FieldValue.arrayUnion([game.toJson()]),
    });
  }

  _addGame(BuildContext context){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Game to Pitcher?'),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Confirm'),
                onPressed: () async {
                  // await DatabaseHelper.instance.add(
                  //   Player(name: _currentPitcher),
                  // );
                  // ignore: unnecessary_brace_in_string_interps
                  int gCheck = checkGames(_pitcherGamesS, _currentTeam, '$month/$day');
                  Map<String, dynamic> game = {
                    'pitcher': _currentPitcher, 'pitches': getPitcher(_currentPitcher).unsaved_pitches,
                    'mm': month, 'dd': day, 'team': _currentTeam, 'opponent': 'N/A',
                    'gNum' : gCheck == 0 ? '' : gCheck + 1,
                  };
                  _createInstance(_currentPitcher, game);
                  print('This is checking how many of this team on day: ${gCheck == 0 ? 'one' : gCheck + 1}');
                  _pitcherGamesS.add(('${game['team']} ${game['mm']}/${game['dd']} ${gCheck == 0 ? '' : gCheck + 1}'));
                  _currentTeam = ' ';
                  _calcCombo(_findPitcher(_currentPitcher).displayPitches);

                  Navigator.pop(context);
                  },
              ),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))
          ]
          )
        );
      }
    );
  }

  int checkGames(List<String> list, String team, String mmdd){
    int count = 0;
    for(String item in list){
      if(item.contains(team) && item.contains(mmdd)){
        count++;
      }
    }
    return count;
  } 

// TODO: Make sure to include dynamic if idea works
  _undoPitch(String pitcher){
    Player p = _findPitcher(_currentPitcher);
    if(current_mode == 'Charting'){
      if (p.unsaved_pitches.isNotEmpty){
        p.unsaved_pitches.removeLast();
        p.total_staple.removeLast();
        p.displayPitches.removeLast();
        _calcCombo(_findPitcher(pitcher).unsaved_pitches);
        setState(() {});
      }
    }
  }

  _calculateCountPerc(List<Pitch> pitches){
    int totps = pitches.length;

    countCounts.forEach((key, value) {countCounts[key] = 0;});

    for(Pitch pitch in pitches){
      if(pitch.oldCount == const Tuple2<int,int> (0,0)){
        if(pitch.strike){
          countCounts['sts'] = countCounts['sts']! + 1;
        } else {
          countCounts['stb'] = countCounts['stb']! + 1;
        }
        countCounts['start'] = countCounts['start']! + 1;

      } else if(pitch.oldCount == const Tuple2<int,int> (1,0)){
        if(pitch.strike){
          countCounts['1bts'] = countCounts['1bts']! + 1;
        } else {
          countCounts['1btb'] = countCounts['1btb']! + 1;
        }
        countCounts['1b0s'] = countCounts['1b0s']! + 1;

      } else if(pitch.oldCount == const Tuple2<int,int> (0,1)){
        if(pitch.strike){
          countCounts['1sts'] = countCounts['1sts']! + 1;
        } else {
          countCounts['1stb'] = countCounts['1stb']! + 1;
        }
        countCounts['0b1s'] = countCounts['0b1s']! + 1;

      } else if(pitch.oldCount == const Tuple2<int,int> (1,1)){
        if(pitch.strike){
          countCounts['1b1sts'] = countCounts['1b1sts']! + 1;
        } else {
          countCounts['1b1stb'] = countCounts['1b1stb']! + 1;
        }
        countCounts['even'] = countCounts['even']! + 1;
      }
    }

    countPercent.forEach((key, value) {countPercent[key] = 0;});

    if(totps > 0){
      int? start = countCounts['start'];
      countPercent['start2ball'] = (countCounts['stb']! / start!) * 100; // 0-0 -> 1-0
      countPercent['start2strike'] = (countCounts['sts']! / start) * 100; // 0-0 -> 0-1

      if(countCounts['1b0s']! > 0){
        int? ball0s = countCounts['1b0s'];
        countPercent['1ball2ball'] = (countCounts['1btb']! / ball0s!) * 100; // 1-0 -> 2-0
        countPercent['1ball2strike'] = (countCounts['1bts']! / ball0s) * 100; // 1-0 -> 1-1
        
        if(countCounts['even']! > 0){
          int? even = countCounts['even'];
          countPercent['even2ball'] = (countCounts['1b1stb']! / even!) * 100; // 1-1 -> 2-1
          countPercent['even2strike'] = (countCounts['1b1sts']! / even) * 100; // 1-1 -> 1-2
        } // 1-0 -> 1-1
      }
      if (countCounts['0b1s']! > 0){
        int? s2ball = countCounts['0b1s'];
        countPercent['1strike2ball'] = (countCounts['1stb']! / s2ball!) * 100; // 0-1 -> 1-1
        countPercent['1strike2strike'] = (countCounts['1sts']! / s2ball) * 100; // 0-1 -> 0-2
        if(countCounts['even']! > 0){
          int? even = countCounts['even'];
          countPercent['even2ball'] = (countCounts['1b1stb']! / even!) * 100; // 1-1 -> 2-1
          countPercent['even2strike'] = (countCounts['1b1sts']! / even) * 100; // 1-1 -> 1-2
        }
      }
    }
  }

  _calculateCount(Pitch prev_pitch){
    current_count = const Tuple2<int,int> (0,0);

    var oldC = prev_pitch.oldCount;

    current_count = oldC;

    if(prev_pitch.hit || prev_pitch.bip){
      current_count = const Tuple2<int,int> (0,0);
    } else if(prev_pitch.bb || prev_pitch.hbp || prev_pitch.k_looking || prev_pitch.k_swinging){
      current_count = const Tuple2<int,int> (0,0);
    } else {
      if(prev_pitch.strike){
        if(oldC.item2 != 2){
          current_count = Tuple2<int,int> (oldC.item1, oldC.item2 + 1);
        } else {
          if(!prev_pitch.foul){
            current_count = const Tuple2<int,int> (0,0);
          }
        }
      } else {
        if(oldC.item1 != 3){
          current_count = Tuple2<int,int> (oldC.item1 + 1, oldC.item2);
        } else {
          current_count = const Tuple2<int,int> (0,0);
        }
      }


    }
  }


  //Updates ranges, averages, and count
  _calculateInfo(List<Pitch> pitches){
    final Map<String, Map<String, dynamic>> cInf = {};
    cExtras.forEach((key, value) => cExtras[key] = 0);
    
    for(String pitch in pitchChoices){
      cInf[pitch] = {'count' : 0, 'spdTot' : 0, 'strike' : 0, 'tot' : 0, 'speeds': []};
    }

    List<int> speed_ints = [];
    int? minspd = 0;
    int? maxspd = 0;


    //Goes through all pitches in the pitch array
    for(Pitch entry in pitches){
      String p_type = entry.type;
      int p_spd = entry.speed;
      bool p_strike = entry.strike;

      p_strike ? {
        cInf[p_type]!['strike'] += 1,
        cExtras['strike_count'] = cExtras['strike_count']! + 1,
      } : 0;
      cInf[p_type]!['tot'] += 1;

      p_spd != 0 ? {
        cInf[p_type]!['count'] += 1,
        cInf[p_type]!['spdTot'] += p_spd,
        cInf[p_type]!['speeds'].add(p_spd)
      } : 0;

      entry.bb ? cExtras['numWalks'] = cExtras['numWalks']! + 1 : 0;
      entry.hbp ? cExtras['numHBP'] = cExtras['numHBP']! + 1 : 0;
      entry.k_looking || entry.k_swinging ? cExtras['numKs'] = cExtras['numKs']! + 1 : 0;
      entry.hit ? cExtras['numHits'] = cExtras['numHits']! + 1 : 0;
      cExtras['pitch_count'] = cExtras['pitch_count']! +  1;
    }

    //Updates and calculates the values for the widgets
    setState((){

      for(String pname in pitchChoices){

          // pitchStats = 'FB' : {'avg' : 0, 'min' : 0, 'max' : 0, 'StrikeP' : 0},
          // cInf[pitch] = {'count' : 0, 'spdTot' : 0, 'strike' : 0, 'tot' : 0, 'speeds': []};

        cInf[pname]!['tot'] != 0 ? {
          pitchStats[pname]!['StrikeP'] = (cInf[pname]!['strike'] !/ cInf[pname]!['tot']) * 100 
        } : pitchStats[pname]!['StrikeP'] = 0;

        cInf[pname]!['count'] != 0 ? {
          speed_ints = List<int>.from(cInf[pname]!['speeds'] ?? []),
          minspd = speed_ints.isNotEmpty ? speed_ints.reduce(min) : 0,
          maxspd = speed_ints.isNotEmpty ? speed_ints.reduce(max) : 0,
          pitchStats[pname]!['avg'] = cInf[pname]!['spdTot'] / cInf[pname]!['count'],
          pitchStats[pname]!['min'] = minspd!.toDouble(),
          pitchStats[pname]!['max'] = maxspd!.toDouble()
        } : {
          pitchStats[pname]!['avg'] = 0,
          pitchStats[pname]!['min'] = 0,
          pitchStats[pname]!['max'] = 0
        };
      }

      _pitch_count = pitches.length;
      if(_pitch_count == 0){
        cExtras['strikeP'] = 0;
        current_count = const Tuple2<int,int> (0,0);
      }else{
        cExtras['strikeP'] = (cExtras['strike_count']! / _pitch_count) * 100;
      }

      cExtras;
      cInf;

      // fb_tot != 0 ? _fbSP = (fb_strikes / fb_tot) * 100 : _fbSP = 0;
    });


  }

  _calcCombo(List<Pitch> pitches){
    // List<Pitch> pitches = _findPitcher(_currentPitcher).total_pitches;

    _calculateInfo(pitches);
    pitches.isNotEmpty ? _calculateCount(pitches.last) : 0;
    _calculateCountPerc(pitches);
    // _currentPitches = pitches;
  }

  Player _findPitcher(String pitcher){
    for(Player player in _pitchPlayer){
      if(player.name == pitcher){
        return player;
      }
    }
    return Player("Not Found");
  }

  _removePitcher(String pitcher){
    List<Player> copyPlayer = List.from(_pitchPlayer);
    for(Player player in copyPlayer){
      if(player.name == pitcher){
        _pitchPlayer.remove(player);
        _Pitchers.remove(pitcher);
      }
    }
    setState(() {});
    _pitcherRemove = " ";
    _currentPitcher = " ";
  }

  _pitchInsight(Pitch pitch, context, List<Pitch> pitches){
    bool updateData = false;
    if(pitch.hdesc != null && pitch.hdesc != Hit(' ', Offset.zero, ' ')){
      updateData = true;
    }
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Pitch Information'),
            content: SizedBox(
              height: updateData ? 500 : 150,
              width: updateData ? 500 : 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('\u2022 Pitch #: ${pitches.indexOf(pitch) + 1}'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                    child: Text("\u2022 Pitch: ${pitch.type}, Speed: ${pitch.speed}")
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("\u2022 ${pitch.strike ? "Strike, ${pitch.foul ? "Fouled" : pitch.k_looking || pitch.k_swinging ? "Strikeout" : 
                    (pitch.swing ? (pitch.hit ? "Hit" : "Swung") : "Looking")}" :
                    "Ball${pitch.bb || pitch.hbp ? ", Walk" : ""}"}"),
                  ),
                  Text("\u2022 Count Thrown in: ${pitch.oldCount}"),

                  if(updateData)
                    sprayWidget(locs: [pitch]),

                ],
              )
            ),
          );
        }
      );
  }

  _addPitch(Pitch pitch, String pitcher){
    Player p = _findPitcher(pitcher);
    List<Pitch> pitches = [];
    pitches.add(pitch);

    p.unsaved_pitches.add(pitch);
    p.displayPitches.add(pitch);
    p.total_staple.add(pitch);
    addPitchesToPitcher(_findPitcher(pitcher), pitches);
  }

  _pitchesRequested(List<String> specs, String pitcher, List<int> i_s) async {
    List<Pitch> final_requested = [];
    Player p = getPitcher(pitcher);
    final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(p.id);
    // p.displayPitches = p.total_staple;

    print(specs);
    // This is a controller that checks to see if the specs are all pitch choices,
    // this is used when I want to check to see if we want to see certain pitches with
    // different certirion

    bool allContained = specs.every((element) => pitchChoices.contains(element));
    List<Pitch> pitch_pool = [];
    List<String> after_game = [];
    List<String> after_type = [];
    List<Pitch> smaller_pool = [];
    Set<Pitch> final_pool = Set<Pitch>();

    if(specs.isNotEmpty){
      bool game = i_s.any((element) => element >= 6);
      // print('Game: ${game}');
      if(game){
        for(String spec in specs){
          if(!pitchChoices.contains(spec) && spec != "Strike" && spec != "Ball"){
            for(var instance in p.games){
              if(spec == '${instance.team} ${instance.mm}/${instance.dd} ${instance.gNum}'){
                pitch_pool.addAll(instance.pitches);
              }
            }
          } else {
            after_game.add(spec);
          }
        }
      } else {
        pitch_pool = p.total_staple;
        after_game.addAll(specs);
      }

      // print('After filtering games: $after_game');
      List<Pitch> c_pitchpool = List.from(pitch_pool);
      if(after_game.isNotEmpty){
        Set<Pitch> game_filtered_pool = Set<Pitch>();
        bool contain = after_game.any((element) => pitchChoices.contains(element));
        if(contain){
          for(String spec in after_game){
            if(pitchChoices.contains(spec)){
              for(Pitch pitch in c_pitchpool){
                if(pitch.type == spec){
                  game_filtered_pool.add(pitch);
                }
              }
            } else {
              after_type.add(spec);
            }
          }
      } else {
        after_type = after_game;
        smaller_pool = pitch_pool;
      }
        contain ? smaller_pool = game_filtered_pool.toList() : 0;
      } else {
        smaller_pool = pitch_pool;
        
      }

      // print('After types: $after_type');
      // print(smaller_pool);
      if(after_type.isNotEmpty){
        Set<Pitch> final_filtered_pool = Set<Pitch>();
        for(String spec in after_type){
          if(spec == "Strike"){
            final_filtered_pool.addAll(smaller_pool.where((pitch) => pitch.strike));
          } else if(spec == "Ball"){
            final_filtered_pool.addAll(smaller_pool.where((pitch) => !pitch.strike));
          }
        }
        final_pool = smaller_pool.toSet().intersection(final_filtered_pool).toSet();
      } else {
        final_pool = smaller_pool.toSet();
      }

      await playerRef.update({
      'displayPitches': final_pool.toList().map((e) => e.toJson()),
      });

      // p.displayPitches = final_pool.toList();
    } else {

      await playerRef.update({
      'displayPitches': p.total_staple.map((e) => e.toJson()),
      'total_dynamic': p.total_staple.map((e) => e.toJson()),
      });

      // p.displayPitches = p.total_staple;
      // p.total_dynamic = p.total_staple;
    }
  }

  bool _rndB(){
    Random random = Random();
    return random.nextBool();
  }

  _testingPitches(int num_pitch){

    Random random = Random();
    Pitch new_pitch;
    Player tester = _findPitcher('Test Pitcher');
    // Strike zone total area: 460 x 495
    for (int i = 0; i < num_pitch; i++) {
      Map<String, dynamic> pitch = {
        'type': pitchChoices[random.nextInt(pitchChoices.length)],
        'spd': random.nextInt(60) + 39,
        'loc_x': random.nextInt(460).toDouble(), 'loc_y': random.nextInt(495).toDouble(),
        'oldCountBalls' : 0, 'oldCountStrikes': 0, 'strike': _rndB(),
        'swing': _rndB(), 'hit': _rndB(), 'K' : _rndB(), 'ꓘ' : _rndB(),
        'hbp': _rndB(), 'bb': _rndB(), 'in_zone': _rndB(), 'foul': _rndB(), 'bip': _rndB()
      };

      new_pitch = Pitch.fromMap(pitch);
      _addPitch(new_pitch, tester.name);
      _calcCombo(_findPitcher(tester.name).displayPitches);
    }

    // tester.addGame(game)

    

  }

  _resetOption(BuildContext content){
    showDialog(
      context: content, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset?'),
          content:
          SizedBox(
            height: 150,
            width: 400,
            child: Column(
              children: [
                const Text(
                  'This WILL reset the current unsaved pitches for',
                  textAlign: TextAlign.center,
                  ),
                  Text(_currentPitcher),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text('Confirm'),
                      onPressed: () => {
                        resetSession(getPitcher(_currentPitcher)),
                        Navigator.pop(context)
                      },
                    ),
                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))
                ]
                )
              ],
            )
          )
          
          
        );
      }
    );
  }

  _undoOption(BuildContext content){
    showDialog(
      context: content,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Undo Pitch?"),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => {
                undoPitchDB(getPitcher(_currentPitcher)),
                Navigator.pop(context)}, child: const Text('Confirm')),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))
            ]
          )
        );
      }
    );
  }
  
  _modeOption(BuildContext content){
    showDialog(
      context: content,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Change Mode?'),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => {_modeSwitch(),Navigator.pop(context)}, child: const Text('Confirm')),
              ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: const Text('Cancel'))
            ]
          )
        );
      }
    );
  }

  _pitcherOption(){
    TextEditingController pitcher_controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Add pitcher?'),
          content: Container(
            height: 300,
            child:Column(
              children: [
                  TextField(
                      controller: pitcher_controller,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        helperText: "Pitcher Name",
                        constraints: BoxConstraints(
                          maxWidth: 125,
                          maxHeight: 35,
                        ),
                      ),
                    ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: () => {
                        if(pitcher_controller.text.isNotEmpty){
                        createPlayer(pitcher_controller.text),
                        Navigator.pop(context)}}, child: const Text('Confirm')),
                      ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: const Text('Cancel'))
                    ]
                  ),
                  const Text("Remove Pitcher?"),
                  DropdownButton<String>(
                    value: _pitcherRemove,
                    onChanged: (String? newVal) {
                      setState(() {
                        _pitcherRemove = newVal!;
                        print('Pitcher to Remove: $_pitcherRemove');
                        print(_findPitcher(_pitcherRemove).name);
                      });
                    },
                    items: _Pitchers.map((String item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                  ),
                ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: () => {_removePitcher(_pitcherRemove), Navigator.pop(context)}, child: const Text('Confirm')),
                      ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: const Text('Cancel'))
                    ]
                  ),
              ]
            )
          )
        );
      }
    );
  }

  _sprayOption(){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return sprayWidget(locs: _currentPitches);
      }
    );
  }

List<bool> isPath = List.filled(BIPpaths.length, false);
String? rslt;

_bip_control() async {
  Hit hit = Hit(' ', const Offset (0,0), ' ');
  Hit? temp = await showDialog<Hit>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 500,
        width: 500,
        child: HittingWidget(),
      );
    },
  );

  if(temp != null){
    setState(() {
      hit = temp;
    });
  }

  await Future.delayed(const Duration(milliseconds: 100));
  
  return hit;
}




  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  
  final CollectionReference pitchersCollection = firestore.collection('players');


void fetchData() {
  pitchersCollection.get().then((QuerySnapshot<Map<String, dynamic>> snapshot) {
    print(snapshot.docs);
  } as FutureOr Function(QuerySnapshot<Object?> value));
}


void printValueType(Map<dynamic, dynamic> map) {
  map.forEach((key, value) {
    print('Key: $key, Value Type: ${value.runtimeType}');
  });
}

Future<Tuple2<List<Player>, List<String>>> fetchPitchers() async {
  final QuerySnapshot<Object?> querySnapshot = await pitchersCollection.get();
  List<String> pnames = [];
  List<Player> pitchers = [];
  for(var player in querySnapshot.docs){
    Map<String,dynamic> p = player.data() as Map<String,dynamic>;
    Map<String, dynamic> pInfo = {};
    for(var item in p.keys){
      if(item == 'name'){
        pInfo[item] = p[item];
      } else if(item == 'id'){
        pInfo[item] = p[item];
      } else {
        pInfo[item] = convertTypesForPitchers(item, p[item]);
      }
    }
    pitchers.add(Player.fromJson(pInfo));
    pnames.add(p['name']);
  }

  // print('${pitchers[0].name}, ${pitchers[0].id}');
  return Tuple2<List<Player>, List<String>>(pitchers, pnames);
}

List convertTypesForPitchers(String key, List data){
  List wanted = [];

  if(key == 'games'){
    if(data.isNotEmpty){
      wanted = data.map((game) => GameInstance.fromJson(game)).toList();
    } else {
      wanted = <GameInstance> [];
    }
  } else {
    
    if(data.isNotEmpty){
      wanted = data.map((pitch) => Pitch.fromJson(pitch)).toList();
    } else {
      wanted = <Pitch> [];
    }
  }
  return wanted;
}

Future<void> addPitcher(Player pitcher) async {
  await pitchersCollection.add(pitcher.toJson());
}

Future<void> createPlayer(String name) async {
  CollectionReference playersCollection = FirebaseFirestore.instance.collection('players');

  DocumentReference newPlayerRef = playersCollection.doc();

  Player player = Player(name);
  player.id = newPlayerRef.id;

  await newPlayerRef.set(player.toJson());
}

void addPitchesToPitcher(Player pitcher, List<Pitch> pitches) async {
  pitcher.unsaved_pitches.addAll(pitches);

  print('This is the pitchers id: ${pitcher.id}');
  // Update the database with the new pitches
  final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(pitcher.id);
  print('Player ref id thing: $playerRef');
  await playerRef.update({
    'unsaved_pitches': FieldValue.arrayUnion(pitches.map((pitch) => pitch.toJson()).toList()),
  });
}

void addPitch(Player pitcher, Pitch pitch) async {
  final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(pitcher.id);
  await playerRef.update({
    'unsaved_pitches': FieldValue.arrayUnion([pitch.toJson()]),
    'displayPitches': FieldValue.arrayUnion([pitch.toJson()]),
    'total_staple': FieldValue.arrayUnion([pitch.toJson()])
  });
}

List<Pitch> convertToPitch(List<dynamic> pitches){
  List<Pitch> finale = [];
  for(var item in pitches){
    Pitch newPitch = Pitch.fromJson(item);
    finale.add(newPitch);
  }
  return finale;
}

Future<void> removeFromDB(String playerId) async {
  CollectionReference playersCollection = FirebaseFirestore.instance.collection('players');

  await playersCollection.doc(playerId).delete();
}

Future<void> undoPitchDB(Player pitcher) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('players')
      .where('name', isEqualTo: pitcher.name)
      .limit(1)
      .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot playerSnapshot = querySnapshot.docs.first;
      Map<String, dynamic>? playerData = playerSnapshot.data() as Map<String, dynamic>?;
      List<dynamic> un_pitches = playerData!['unsaved_pitches'];
      List<dynamic> tot_stap = playerData['total_staple'];
      List<dynamic> disp = playerData['displayPitches'];


      if (un_pitches.isNotEmpty && current_mode == "Charting") {
        un_pitches.removeLast();
        tot_stap.removeLast();
        disp.removeLast();


        await playerSnapshot.reference.update({'unsaved_pitches': un_pitches, 
                                               'total_staple' : tot_stap,
                                               'displayPitches': disp});
        print('Last pitch removed successfully.');
      } else {
        print('No pitches to remove.');
      }
  } else {
    print('Pitcher not found.');
  }
}

Future<void> resetSession(Player pitcher) async {
  final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(pitcher.id);
  await playerRef.update({
    'unsaved_pitches': [],
    'displayPitches': []
  });
}

Player getPitcher(String pitcher){
  Player p_pitcher = Player(' ');
  for(Player player in _p_pitchers){
    if(player.name == pitcher){
      p_pitcher = player;
    }
  }
  return p_pitcher;
}

//The Program
  @override
  Widget build(BuildContext context) {
    Size dellySkellys = MediaQuery.of(context).size;
    String dropDownValue = 'Pitcher';
    String dropDownTeam = 'Team';
    // Added sort here, might not work because of this
    _Pitchers.sort();
    _Teams.sort();
    TextEditingController pitcher_controller = TextEditingController();
    late String selectedValue = 'testing';

    List<Map> settings = [
    {
      'name': 'Export',
      'icon': Icons.import_export,
      'function': () {_printScreen();},
    },
    {
      'name': 'Reset Pitcher',
      'icon': Icons.refresh,
      'function': () {_resetOption(context);},
    },
    {
      'name': 'Add Game to Pitcher',
      'icon': Icons.add_chart,
      'function': () {_addGame(context);},
    },
    {
      'name': 'Undo Pitch',
      'icon': Icons.undo,
      'function': () {_undoOption(context);},
    },
    {
      'name': 'Change Mode: $current_mode',
      'icon': Icons.mode,
      'function': () {_modeOption(context);},
    },
    {
      'name': 'Reset Count',
      'icon': Icons.numbers,
      'function': () {_newCount();},
    },
    {
      'name': 'Add/Remove Pitcher',
      'icon': Icons.settings,
      'function': () {_pitcherOption();},
    },
    {
      'name': 'Spray Chart',
      'icon': Icons.compass_calibration_outlined,
      'function': () {_sprayOption();}
    },
  ];


    // Fetching data
    fetchPitchers().then((tuple) {
      // Do something with the fetched pitchers
      _p_pitchers = tuple.item1;
      setState(() {
        if(_Pitchers.isEmpty){
          _Pitchers.addAll(tuple.item2);
          // print('Adding pitchers');
          // print(_Pitchers);
        } else if(_Pitchers != tuple.item2){
          _p_pitchers = tuple.item1;
          _Pitchers = tuple.item2;
        }
      });
    }).catchError((error) {
      // Handle the error
      print('Error fetching pitchers: $error');
    });
    

    // for(String pitcher in _Pitchers){
    //   _pitchPlayer.add(Player(pitcher));
    // }
    

    _currentPitches = getPitcher(_currentPitcher).displayPitches;
    _calcCombo(_currentPitches);
    

    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: RepaintBoundary(
          key: _printKey,
          child:
            Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/new_Chart.png"),),
                ),
              ),
              // Menu Top right
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child:
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, 
                        width: 2.0, 
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: 
                    DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        customButton: const Icon(
                          Icons.list,
                          size: 80,
                          color: Color.fromARGB(255, 47, 50, 52),
                        ),
                        isExpanded: true,
                        items: settings
                            .map((item) => DropdownMenuItem<String>(
                                  value: item['name'],
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Icon(item['icon']),
                                      ),
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        value: 'Export',
                        onChanged: (value) {
                          int index = (settings.indexWhere((item) => item['name'] == value));
                          if (index != -1) {
                            final selectedFunction = settings[index]['function'];
                            selectedFunction();
                          }
                          setState(() {});
                        },
                        dropdownStyleData: DropdownStyleData(
                          width: 300,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                          elevation: 8,
                          offset: const Offset(0, 8),
                        ),
                      ),
                    ),
                  ),
              ),

              //Pitcher Dropdown
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 50, width: 210, off1: dellySkellys.width - 425, off2: 70),
                child: DropdownButton<String>(
                  value: _currentPitcher,
                  onChanged: (String? newValue) async {
                    Player p = getPitcher(newValue!);
                    final DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(p.id);
                    await playerRef.update({
                      'displayPitches': p.unsaved_pitches.map((e) => e.toJson()),
                    });
                    setState(() {
                      
                      // print('Player ID: ${p.id}');
                      // print('Player Pitches ${p.displayPitches}');
                      _currentPitcher = p.name;
                      // print('Current Pitcher: $_currentPitcher');
                      _currentPitches = p.displayPitches;
                      _currentPitches.isNotEmpty ? (_currentPitches.last) : 0;
                      _pitcherGamesG = p.games.isEmpty ? [] : 
                                        p.games;
                      

                      // TODO: Here is the start for the certain selections
                      _pitcherGamesS = ['FB', 'CB', 'CH', 'SL', 'Strike', 'Ball'];

                      if(_pitcherGamesG.isNotEmpty){
                        for(var game in _pitcherGamesG){
                          _pitcherGamesS.add(game.getDisplayText());
                        }
                      }
                      
                      
                    });
                  },
                  items: _Pitchers.map((String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                )
              ),

              //Date Display
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 50, width: 175, off1: dellySkellys.width - 450, off2: 118),
                child: Row(
                  children: [
                    Text(
                      '$month / $day / $year',
                      style: const TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold
                      )
                    )
                  ],
                )
              ),
              
              //Dropdown for games when Db is added
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 45, width: 175, off1: dellySkellys.width - 300, off2: 118),
                child: DropDownMultiSelect(
                  // TODO: This Next
                  onChanged: (List<String> x) {
                    setState(() {
                      selected = x;
                      List<int>sel_i = [];
                      for(var item in x){
                        sel_i.add(_pitcherGamesS.indexOf(item));
                      }
                      sel_i.sort();
                      if(current_mode == "Viewing"){
                        _pitchesRequested(x, _currentPitcher, sel_i);
                        _calcCombo(_findPitcher(_currentPitcher).displayPitches);
                        pitchWidget;
                      }
                      
                    });
                  },
                  selectedValues: selected,
                  whenEmpty: 'History',
                  options: _pitcherGamesS,
                  decoration: const InputDecoration(border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                    )
                  ),
                  
                )

              ),

              //Team Dropdown
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 50, width: 120, off1: dellySkellys.width - 370, off2: 170), 
                child: DropdownButton<String>(
                  value: _currentTeam,
                  onChanged: (String? newValue) {
                    setState(() {
                      _currentTeam = newValue!;
                      print(_currentTeam);
                    });
                  },
                  items: _Teams.map((String item) =>
                  DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
                )
              ),
                
              //StrikeZone + newPitch function
              Stack(
                children: [
                  CustomSingleChildLayout(delegate: DellySkelly(widgetSize: dellySkellys, height: 504, width: 460, off1: (dellySkellys.width / 2) - 395, off2: (dellySkellys.height / 2) - 300),
                  child:
                    pitchWidget = PitchWidget(
                      key: UniqueKey(),
                      pitches: _currentPitches,
                    )
                  ),
                  CustomSingleChildLayout(delegate: DellySkelly(widgetSize: dellySkellys, height: 504, width: 460, off1: (dellySkellys.width / 2) - 395, off2: (dellySkellys.height / 2) - 300),
                    child:
                      RepaintBoundary(
                        child: DottedBorder(
                          color: Colors.black,
                          dashPattern: const [1, 3],
                          strokeWidth: 4,
                            child: Container(
                              color: Colors.transparent,
                              height: 500,
                              width: 460,
                            )
                        ),
                      ),
                  ),
                  CustomSingleChildLayout(
                    delegate: DellySkelly(widgetSize: dellySkellys, height: 504, width: 460, off1: (dellySkellys.width / 2) - 395, off2: (dellySkellys.height / 2) - 300),
                    child:
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapDown: (TapDownDetails details){
                            Pitch new_pitch;
                            TextEditingController textController = TextEditingController();
                            isPType = List.filled(4, false);
                            isPAction = List.filled(8, false);
                            Map<String, dynamic> pMap = {
                              'type' : '', 'spd' : 0, 'loc_x' : 0, 'loc_y' : 0,
                              'oldCountBalls' : 0, 'oldCountStrikes' : 0,
                              'strike' : false, 'swing' : false, 'hit' : false,
                              'K' : false, 'ꓘ' : false, 'hbp' : false, 'bb' : false,
                              'in_zone' : false, 'foul' : false, 'bip' : false,
                              'hdesc' : Hit(' ', const Offset(0,0), ' ')
                            };
                            pMap['oldCountBalls'] = current_count.item1;
                            pMap['oldCountStrikes'] = current_count.item2;
                            pMap['loc_x'] = details.localPosition.dx;
                            pMap['loc_y'] = details.localPosition.dy;
                            // Swing, Foul, Hit, BB, HBP, K, ꓘ, BIP
                            // 
                          
                            //Checks to see if pitch is a strike soley based on location
                            if(details.localPosition.dx > 105 && details.localPosition.dx < 370){
                              if(details.localPosition.dy > 18 && details.localPosition.dy < 320){
                                pMap['strike'] = true;
                                pMap['in_zone'] = true;
                              }
                            }
                            //Creates the popup and enables information input
                            if(current_mode == "Charting"){
                            var ret2 = showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Pitch Information"),
                                  content: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState){
                                    return Container(
                                      height: 500,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Pitch Type'),
                                          const SizedBox(height: 5),
                                          ToggleButtons(
                                            direction: Axis.horizontal,
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            selectedBorderColor: Colors.red[700],
                                            selectedColor: Colors.white,
                                            fillColor: Colors.red[200],
                                            color: Colors.red[400],
                                            constraints: const BoxConstraints(
                                              minHeight: 50.0,
                                              minWidth: 100.0,
                                            ),
                                            isSelected: isPType,
                                            onPressed: (int index) {
                                            setState(() {
                                              for (int i = 0; i < isPType.length; i++) {
                                                isPType[i] = i == index;
                                                if (index == 0){pMap['type'] = "FB";}
                                                else if(index == 1){pMap['type'] = "CB";}
                                                else if(index == 2){pMap['type'] = "CH";}
                                                else if(index == 3){pMap['type'] = "SL";}
                                              }
                                            });
                                          },
                                            children: PTypes,
                                          ),
                                          const SizedBox(height: 15),
                                          const Text('Speed: '),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: textController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              helperText: "Enter Speed",
                                              constraints: BoxConstraints(
                                                maxWidth: 125,
                                                maxHeight: 35,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height:15),

                                          //Determines if anything happened during Pitch
                                          const Text("Action"),
                                          const SizedBox(height: 10),
                                          ToggleButtons(
                                            direction: Axis.horizontal,
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            selectedBorderColor: Colors.red[700],
                                            selectedColor: Colors.white,
                                            fillColor: Colors.red[200],
                                            color: Colors.red[400],
                                            constraints: const BoxConstraints(
                                              minHeight: 50.0,
                                              minWidth: 85.0,
                                            ),
                                            isSelected: isPAction,
                                            onPressed: (int index) async {
                                              setState(() {
                                                if(index == 0){pMap['swing'] = !pMap['swing']; isPAction[index];}
                                                if(index == 1){pMap['swing'] = !pMap['swing']; pMap['foul'] = !pMap['foul'];}
                                                if(index == 2){
                                                    pMap['swing'] = !pMap['swing']; pMap['hit'] = !pMap['hit'];
                                                    isPAction[index] = pMap['bip'] = !pMap['bip'];}
                                                if(index == 3){pMap['bb'] = !pMap['bb'];}
                                                if(index == 4){pMap['hbp'] = !pMap['hbp'];}
                                                if(index == 5){pMap['swing'] = !pMap['swing']; pMap['K'] = !pMap['K'];}
                                                if(index == 6){pMap['ꓘ'] = !pMap['ꓘ'];}
                                                if(index == 7){pMap['swing'] = !pMap['swing']; pMap['bip'] = !pMap['bip'];}
                                                if(pMap['swing'] || pMap['ꓘ']){pMap['strike'] = true;}

                                                isPAction = [pMap['swing'], pMap['foul'],
                                                            pMap['hit'], pMap['bb'], pMap['hbp'],
                                                            pMap['K'], pMap['ꓘ'], pMap['bip']];
                                              });

                                                if(index == 2 && pMap['hit']|| index == 7 && pMap['bip']){
                                                  Hit? hit = await _bip_control();
                                                    if (hit != null) {
                                                      setState(() {
                                                        pMap['hdesc'] = hit;
                                                      });
                                                    }
                                                }
                                              },
                                            children: PActions,
                                            ),
                                            
                                          ]
                                          )
                                      );
                                        
                                    }
                                    
                                  ),
                                  
                                  actions: <Widget>[
                                    //On pressed, checks to see if speed is available, if not, sets to 0, 
                                    //then creates a Pitch using the information gathered from buttons, increments pitch_count
                                    ElevatedButton(
                                      onPressed: () => {if(pMap['type'] != ''){
                                        if(textController.text.isEmpty){
                                          pMap['spd'] = 0
                                          } else {
                                            pMap['spd'] = int.parse(textController.text)
                                          },
                                        new_pitch = Pitch.fromMap(pMap),
                                        _cPitchLocations.add(new_pitch.location), 
                                        addPitch(getPitcher(_currentPitcher), new_pitch),
                                        _calcCombo(getPitcher(_currentPitcher).displayPitches),
                                        Navigator.pop(context)}}, 
                                      child: const Text('Confirm')
                                    ),        
                                  ],
                                );
                                }
                              );
                            } else if (current_mode == "Viewing"){
                              for (Pitch entry in _currentPitches){
                                if(entry.getArea().contains(details.localPosition)){
                                  _pitchInsight(entry, context, _currentPitches);
                                }
                              }
                              // print(_currentPitches);
                            }
                          },
                        ),
                  ),
                ],
            ),
              
              
              //Outing information box
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 135, width: 150, off1: (dellySkellys.width) - 200, off2: 300),
                  child:
                    DottedBorder(
                      color: Colors.black,
                      dashPattern: const [1, 3],
                      strokeWidth: 0,
                      child: Container(
                        height: 600,
                        width: 200,
                        child: Column(
                          children: [
                            Text("Pitch Count: ${cExtras['pitch_count']!.toInt()}", style: const TextStyle(fontSize: 18)),
                            Text("Strike %: ${cExtras['strikeP']!.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18)),
                            Text("Ks: ${cExtras['numKs']!.toInt()}", style: const TextStyle(fontSize: 18)),
                            Text("Hits: ${cExtras['numHits']!.toInt()}", style: const TextStyle(fontSize: 18)),
                            Text("BBs: ${cExtras['numWalks']!.toInt()}", style: const TextStyle(fontSize: 18)),
                            Text("HBPs: ${cExtras['numHBP']!.toInt()}", style: const TextStyle(fontSize: 18))
                          ]
                        ),
                      ),
                    ),
              ),

              //PitchInformation Box
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 400, width: 200, off1: (dellySkellys.width) - 315, off2: (dellySkellys.height) - 535),
                  child:
                    DottedBorder(
                      color: Colors.black,
                      dashPattern: const [1, 3],
                      strokeWidth: 1,
                      child: Container(
                        height: 400,
                        width: 200,
                        child: Column(
                          children: [
                            Text("FB avg: ${pitchStats['FB']!['avg']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
                            Text("FB S%: ${pitchStats['FB']!['StrikeP']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),
                            Text("${pitchStats['FB']!['min']!.toStringAsFixed(2)} -- ${pitchStats['FB']!['max']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),

                            Text("CB avg: ${pitchStats['CB']!['avg']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
                            Text("CB S%: ${pitchStats['CB']!['StrikeP']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),
                            Text("${pitchStats['CB']!['min']!.toStringAsFixed(2)} -- ${pitchStats['CB']!['max']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),

                            Text("CH avg: ${pitchStats['CH']!['avg']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
                            Text("CH S%: ${pitchStats['CH']!['StrikeP']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),
                            Text("${pitchStats['CH']!['min']!.toStringAsFixed(2)} -- ${pitchStats['CH']!['max']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),

                            Text("SL avg: ${pitchStats['SL']!['avg']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
                            Text("SL S%: ${pitchStats['SL']!['StrikeP']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),
                            Text("${pitchStats['SL']!['min']!.toStringAsFixed(2)} -- ${pitchStats['SL']!['max']!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),

                            const Text(''),
                            
                            Text("In 0-0 Counts: ${countCounts['start']}"),
                            Text("1-0: ${countPercent['start2ball']!.toStringAsFixed(0)}%, 0-1: ${countPercent['start2strike']!.toStringAsFixed(0)}%"),

                            Text("In 1-0 Counts: ${countCounts['1b0s']}"),
                            Text("2-0: ${countPercent['1ball2ball']!.toStringAsFixed(0)}%, 1-1: ${countPercent['1ball2strike']!.toStringAsFixed(0)}%"),

                            Text("In 0-1 Counts: ${countCounts['0b1s']}"),
                            Text("1-1: ${countPercent['1strike2ball']!.toStringAsFixed(0)}%, 0-2: ${countPercent['1strike2strike']!.toStringAsFixed(0)}%"),

                            Text("In 1-1 Counts: ${countCounts['even']}"),
                            Text("2-1: ${countPercent['even2ball']!.toStringAsFixed(0)}%, 1-2: ${countPercent['even2strike']!.toStringAsFixed(0)}%"),

                          ]
                        ),
                      ),
                    ),
                ),

                //Count Information Box
                CustomSingleChildLayout(
                  delegate: DellySkelly(widgetSize: dellySkellys, height: 60 , width: 75, off1: (dellySkellys.width) - 320, off2: 300),
                  child: 
                    DottedBorder(
                      color: Colors.black,
                      dashPattern: const [1, 3],
                      strokeWidth: 1,
                      child: Container(
                        height: 60,
                        width: 75,
                        child: Column (
                          children: [
                            const Text('Count', style: TextStyle(fontSize: 20)),
                            Text("${current_count.item1} - ${current_count.item2}",
                              style: const TextStyle(fontSize: 20))],
                        )
                      )
                    ),
                )

                ]
          )
        )
      ),
    );
  }

}