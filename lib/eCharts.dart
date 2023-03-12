// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable, constant_identifier_names, file_names

import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/rendering.dart';
// import 'package:my_app/database.dart';
// import 'package:my_app/database_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'Baseball_Pieces/Player.dart';
import 'Baseball_Pieces/Pitch.dart';
import 'Baseball_Pieces/paintPitch.dart';
import 'HomePage.dart';
import 'GameInstance.dart';
import 'package:multiselect/multiselect.dart';
import 'package:tuple/tuple.dart';
import 'package:touchable/touchable.dart';
import 'DellySkelly.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';


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



class eCharts extends State<HomePage> {

  List<Pitch> _currentPitches = [];
  List<Offset> _cPitchLocations = [];
  List<Pitch> _displayPitches = [];
  List<Offset> _displayLocations = [];
  int _pitch_count = 0;
  double _fb_avg = 0; int _fb_min = 0; int _fb_max = 0;
  double _ch_avg = 0; int _ch_min = 0; int _ch_max = 0;
  double _cb_avg = 0; int _cb_min = 0; int _cb_max = 0;
  double _sl_avg = 0; int _sl_min = 0; int _sl_max = 0;
  int _numHits = 0; int _numWalks = 0; int _numHBP = 0;
  int _numKs = 0; double _strikePercentage = 0;

  double _fbSP = 0; double _cbSP = 0;
  double _chSP = 0; double _slSP = 0;


  int _stb = 0; int _sts = 0; 
  int _1bts = 0; int _1btb = 0;
  int _1stb = 0; int _1sts = 0;
  int _start = 0; int _1b0s = 0;
  int _0b1s = 0; 
  int _1b1sts = 0; int _1b1stb = 0;
  int _even = 0;

  double _start2ball = 0; double _start2strike = 0;
  double _1ball2ball = 0; double _1ball2strike = 0;
  double _1strike2ball = 0; double _1strike2strike = 0;
  double _even2ball = 0; double _even2strike = 0;


  Color? modeColor = Colors.blue[600];
  String current_mode = "Charting";
  Tuple2<int,int> current_count = Tuple2<int,int> (0,0);
  
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  final List<String> _Pitchers = [' ', 'Andrei Stoyanow', 'Bobby Fowler', 'Cade McWilliams', 'Connor Stack', 'David Blackburn',
                                  'Ethan Thomas', 'Gunner Hopkins', 'Hogan Ralston', 'Jack Hodgins', 'Jackson Corrigan', 'Jacob Wagner', 'John Henry Fowler', 
                                  'John Schaller', 'Johnny Miles', 'Kyle Poissoit', 'Miles Schluterman', 'Nathan Silva', 'Patrick Chastain', 
                                  'Ryan da best eva Torres', 'Teddy Olander', 'Tyler Meek', 'Aiden Leggit', 'Brax Waller', 'Bryson Bales', 'Caleb Ougel',
                                  'Chance Reed', 'Chase Nials', 'JD Nichols', 'Kyler Oathout', 'Matthew Mitchell', 'Miko Djuric', 'Nate Hirsh',
                                  'Nic Luna', 'Sam Collier', 'Trent Jordan', 'Tucker Isbell', 'William Kuebler', 'Wyatt Goodman', 'Zane Nolan',
                                  'Ian Guthrie'];
  
  List<GameInstance> _pitcherGamesG = [];
  List<String> _pitcherGamesS = ['FBs', 'CBs', 'CHs', 'SLs'];


  String _currentPitcher = " ";
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

  
  getGames(Player pitcher){
    return pitcher.games;
  }

  void _printScreen(){
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await WidgetWraper.fromKey(
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
    current_count = Tuple2<int,int> (0,0);
    setState(() {});
  }

  _reset(String pitcher){
    _pitchPlayer[_Pitchers.indexOf(pitcher)].total_pitches = [];
    _currentPitcher = " ";
    _currentTeam = ' ';
    _cPitchLocations = [];
    _numHBP = 0; _numHits = 0; _numKs = 0; _numWalks = 0; _pitch_count = 0;
    _strikePercentage = 0;
    _fb_avg = 0; _fb_min = 0; _fb_max = 0;
    _ch_avg = 0; _ch_min = 0; _ch_max = 0;
    _cb_avg = 0; _cb_min = 0; _cb_max = 0;
    _sl_avg = 0; _sl_min = 0; _sl_max = 0;
    _fbSP = 0; _cbSP = 0; _chSP = 0; _slSP = 0;
    _calculateCountPerc([]);
    setState(() {});
    current_count = Tuple2<int,int> (0,0);
  }

  _modeSwitch(){
    if(current_mode == "Charting"){
      current_mode = "Viewing";
      modeColor = Colors.redAccent;
    } else {
      current_mode = "Charting";
      modeColor = Colors.blue;
    }
    setState(() {});
  }


  _createInstance(Player pitcher, List<Pitch> pitches, String mm, String dd, String team){
    var game = GameInstance(pitches, pitcher, team, mm, dd);
    // pitcher.setId(savePitcher(pitcher));
    pitcher.addGame(game);
    print(game.pitcher);
    print(game.pitches);
    print(game.mm);
    print(game.dd);
    print(game.team);
    _reset(pitcher.name);
  }


  _undoPitch(String pitcher){
    List<Pitch> pitches = _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].total_pitches;
    if (pitches.isNotEmpty){
      pitches.removeLast();
      _cPitchLocations.removeLast();
      _calcCombo(pitcher);
      setState(() {});
    }
  }

  _calculateCountPerc(List<Pitch> pitches){

    _stb = 0; _sts = 0; 
    _1bts = 0; _1btb = 0;
    _1stb = 0; _1sts = 0;
    _start = 0; _1b0s = 0;
    _0b1s = 0; 
    _1b1sts = 0; _1b1stb = 0;
    _even = 0;
    int totps = pitches.length;

    for(Pitch pitch in pitches){
      if(pitch.oldCount == Tuple2<int,int> (0,0)){
        if(pitch.strike){
          _sts += 1;
        } else {
          _stb += 1;
        }
        _start += 1;

      } else if(pitch.oldCount == Tuple2<int,int> (1,0)){
        if(pitch.strike){
          _1bts += 1;
        } else {
          _1btb += 1;
        }
        _1b0s += 1;
      } else if(pitch.oldCount == Tuple2<int,int> (0,1)){
        if(pitch.strike){
          _1sts += 1;
        } else {
          _1stb += 1;
        }
        _0b1s += 1;
      } else if(pitch.oldCount == Tuple2<int,int> (1,1)){
        if(pitch.strike){
          _1b1sts += 1;
        } else {
          _1b1stb += 1;
        }
        _even += 1;
      }
    }

    _start2ball = 0; _start2strike = 0;
    _1ball2ball = 0; _1ball2strike = 0;
    _1strike2ball = 0; _1strike2strike = 0;
    _even2ball = 0; _even2strike = 0;

    if(totps > 0){
      _start2ball = (_stb / _start) * 100;// 0-0 -> 1-0
      _start2strike = (_sts / _start) * 100; // 0-0 -> 0-1
      if(_1b0s > 0){
        _1ball2ball = (_1btb / _1b0s) * 100; // 1-0 -> 2-0
        _1ball2strike = (_1bts / _1b0s) * 100;
        if(_even > 0){
          _even2ball = (_1b1stb / _even) * 100; // 1-1 -> 2-1
          _even2strike = (_1b1sts / _even) * 100; // 1-1 -> 1-2
        } // 1-0 -> 1-1
      }
      if (_0b1s > 0){
        _1strike2ball = (_1stb / _0b1s) * 100; // 0-1 -> 1-1
        _1strike2strike = (_1sts / _0b1s) * 100; // 0-1 -> 0-2
        if(_even > 0){
          _even2ball = (_1b1stb / _even) * 100; // 1-1 -> 2-1
          _even2strike = (_1b1sts / _even) * 100; // 1-1 -> 1-2
        }
      }
    }
  }

  _calculateCount(Pitch prev_pitch){
    current_count = Tuple2<int,int> (0,0);

    var oldC = prev_pitch.oldCount;

    current_count = oldC;

    if(prev_pitch.hit || prev_pitch.bip){
      current_count = Tuple2<int,int> (0,0);
    } else if(prev_pitch.bb || prev_pitch.hbp || prev_pitch.k_looking || prev_pitch.k_swinging){
      current_count = Tuple2<int,int> (0,0);
    } else {
      if(prev_pitch.strike){
        if(oldC.item2 != 2){
          current_count = Tuple2<int,int> (oldC.item1, oldC.item2 + 1);
        } else {
          if(!prev_pitch.foul){
            current_count = Tuple2<int,int> (0,0);
          }
        }
      } else {
        if(oldC.item1 != 3){
          current_count = Tuple2<int,int> (oldC.item1 + 1, oldC.item2);
        } else {
          current_count = Tuple2<int,int> (0,0);
        }
      }


    }
  }


  //Updates ranges, averages, and count
  _calculateInfo(List<Pitch> pitches){
    int fb_count = 0; int fb_speed_tot = 0; 
    List<int> fb_speeds = []; int fb_strikes = 0;
    int fb_tot = 0;

    int ch_count = 0; int ch_speed_tot = 0;
    List<int> ch_speeds = []; int ch_strikes = 0;
    int ch_tot = 0;

    int cb_count = 0; int cb_speed_tot = 0;
    List<int> cb_speeds = []; int cb_strikes = 0;
    int cb_tot = 0;

    int sl_count = 0; int sl_speed_tot = 0;
    List<int> sl_speeds = []; int sl_strikes = 0; 
    int sl_tot = 0;

    int strike_count = 0;
    _numHBP = 0; _numHits = 0;
    _numKs = 0; _numWalks = 0;



    //Goes through all pitches in the pitch array
    for(Pitch entry in pitches){
      String p_type = entry.type;
      int p_spd = entry.speed;
      bool p_strike = entry.strike;

      //Gathers pitch information based on type
      if(p_type == "FB"){
        p_strike ? fb_strikes += 1 : fb_strikes;
        fb_tot += 1;
        if(p_spd != 0){
          fb_count += 1;
          fb_speed_tot += p_spd;
          fb_speeds.add(p_spd);
        }
      }else if(p_type == "CH"){
        p_strike ? ch_strikes += 1 : ch_strikes;
        ch_tot += 1;
        if(p_spd != 0){
          ch_count += 1;
          ch_speed_tot += p_spd;
          ch_speeds.add(p_spd);
        }
      }else if(p_type == "CB"){
        p_strike ? cb_strikes += 1 : cb_strikes;
        cb_tot += 1;
        if(p_spd != 0){
          cb_count += 1;
          cb_speed_tot += p_spd;
          cb_speeds.add(p_spd);
        }
      } else if(p_type == "SL"){
        p_strike ? sl_strikes += 1 : sl_strikes;
        sl_tot += 1;
        if(p_spd != 0){
          sl_count += 1;
          sl_speed_tot += p_spd;
          sl_speeds.add(p_spd);
        }
      }

      if(p_strike){
        strike_count += 1;
      }

      if(entry.bb){_numWalks += 1;}
      if(entry.hbp){_numHBP += 1;}
      if(entry.k_looking || entry.k_swinging){_numKs += 1;}
      if(entry.hit){_numHits += 1;}


    }

    //Updates and calculates the values for the widgets
    setState((){
      fb_tot != 0 ? _fbSP = (fb_strikes / fb_tot) * 100 : _fbSP = 0;
      if(fb_count != 0){
        _fb_avg = fb_speed_tot / fb_count;
        _fb_min = fb_speeds.reduce(min);
        _fb_max = fb_speeds.reduce(max);
      } else {
        _fb_avg = 0; _fb_min = 0; _fb_max = 0;
      }

      ch_tot != 0 ? _chSP = (ch_strikes / ch_tot) * 100 : _chSP = 0;
      if(ch_count != 0){
        _ch_avg = ch_speed_tot / ch_count;
        _ch_min = ch_speeds.reduce(min);
        _ch_max = ch_speeds.reduce(max);
        _chSP = (ch_strikes / ch_tot) * 100;
      } else {
        _ch_avg = 0; _ch_min = 0; _ch_max = 0;
      }

      cb_tot != 0 ? _cbSP = (cb_strikes / cb_tot) * 100: _cbSP = 0;
      if(cb_count != 0){
        _cb_avg = cb_speed_tot / cb_count;
        _cb_min = cb_speeds.reduce(min);
        _cb_max = cb_speeds.reduce(max);
        _cbSP = (cb_strikes / cb_tot) * 100;
      } else {
        _cb_avg = 0; _cb_min = 0; _cb_max = 0;
      }

      sl_tot != 0 ? _slSP = (sl_strikes / sl_tot) * 100: _slSP = 0;
      if(sl_count != 0){
        _sl_avg = sl_speed_tot / sl_count;
        _sl_min = sl_speeds.reduce(min);
        _sl_max = sl_speeds.reduce(max);
        _slSP = (sl_strikes / sl_tot) * 100;
      } else {
        _sl_avg = 0; _sl_min = 0; _sl_max = 0;
      }

      _pitch_count = _currentPitches.length;
      if(_pitch_count == 0){
        _strikePercentage = 0;
        current_count = Tuple2<int,int> (0,0);
      }else{
        _strikePercentage = (strike_count / _pitch_count) * 100;
      }
      _pitch_count;
      _numHits;
      _numKs;
      _numWalks;
      _numWalks;
      _numHBP;
      
    });


  }

  _calcCombo(String pitcher){
    List<Pitch> pitches = _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].total_pitches;

    _calculateInfo(pitches);
    pitches.isNotEmpty ? _calculateCount(pitches.last) : print('empty');
    _calculateCountPerc(pitches);
    _currentPitches = pitches;
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
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String year = DateTime.now().year.toString();


    for(String pitcher in _Pitchers){
      _pitchPlayer.add(Player(pitcher));
    }

    _currentPitches = _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].total_pitches;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: RepaintBoundary(
          key: _printKey,
          child:
            Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/new_Chart.png"),),
                ),
              ),
              
              // FutureBuilder<List<Player>>(
              //   future: DatabaseHelper.instance.getPitchers(),
              //   builder: (BuildContext context, AsyncSnapshot<List<Player>> snapshot){
              //     if (!snapshot.hasData){
              //       return Center(child: Text('Loading...', style: TextStyle(fontSize: 30)));
              //     }
              //     return snapshot.data!.isEmpty
              //     ? Center(child: Text('Testing'))
                  
              //     : ListView(
              //       children: snapshot.data!.map((pitcher) {
              //         return Center(
              //           child: ListTile(
              //             title: Text(pitcher.name),
              //           ),
              //         );
              //       }).toList(),
              //     );
              //   }
              // ),
              
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  FloatingActionButton(
                  child: const Icon(Icons.download),
                  onPressed: _printScreen,
                  ),
                  FloatingActionButton(
                    child: Icon(Icons.fiber_new),
                    onPressed: () => {
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Reset?'),
                            content: 
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  child: Text('Confirm'),
                                  onPressed: () => {
                                    _reset(_currentPitcher),
                                    Navigator.pop(context)
                                  },
                                ),
                                ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                            ]
                            )
                            
                          );
                        }
                      )
                    }
                  ),
                  FloatingActionButton(onPressed: () => {
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Add Game to Pitcher?'),
                            content: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  child: Text('Confirm'),
                                  onPressed: () async {
                                    // await DatabaseHelper.instance.add(
                                    //   Player(name: _currentPitcher),
                                    // );
                                    GameInstance test_Hist = _createInstance(_pitchPlayer[_Pitchers.indexOf(_currentPitcher)],
                                    _currentPitches, month, day, _currentTeam);
                                    _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].addGame(test_Hist);
                                    setState(() {_pitcherGamesG;});
                                    Navigator.pop(context);
                                    },
                                ),
                                ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                            ]
                            )
                          );
                        }
                      )
                  }, child: Icon(Icons.add_chart)),
                  FloatingActionButton(onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Undo Pitch?"),
                          content: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(onPressed: () => {_undoPitch(_currentPitcher), Navigator.pop(context)}, child: Text('Confirm')),
                              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                            ]
                          )
                        );
                      }
                    ),
                  }, child: Icon(Icons.undo)),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(onPressed: () => {
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text('Change Mode?'),
                            content: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(onPressed: () => {_modeSwitch(), Navigator.pop(context)}, child: Text('Confirm')),
                                ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: Text('Cancel'))
                              ]
                            )
                          );
                        }
                      )
                    }, child: Text(current_mode), style: ElevatedButton.styleFrom(primary: modeColor))
                    ),
                    SizedBox(
                    height: 40,
                    child: ElevatedButton(onPressed: () => {
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text('Reset Count?'),
                            content: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(onPressed: () => {_newCount(), Navigator.pop(context)}, child: Text('Confirm')),
                                ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: Text('Cancel'))
                              ]
                            )
                          );
                        }
                      )
                    }, child: Text('New Count'), style: ElevatedButton.styleFrom(primary: modeColor))
                    ),
                ]
              ),

              //Pitcher Dropdown
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 50, width: 204, off1: dellySkellys.width - 425, off2: 70),
                child: DropdownButton<String>(
                  value: _currentPitcher,
                  onChanged: (String? newValue) {
                    setState(() {
                      _currentPitcher = newValue!;
                      print(_pitchPlayer[_Pitchers.indexOf(_currentPitcher)].name);
                      _currentPitches = _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].total_pitches;
                      _currentPitches.isNotEmpty ? (_currentPitches.last) : print('empty');
                      _calculateCountPerc(_currentPitches);
                      _calculateInfo(_currentPitches);
                      _pitcherGamesG = _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].games.isEmpty ? [] : 
                                        _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].games;
                      
                      _pitcherGamesS = ['FBs', 'CBs', 'CHs', 'SLs'];

                      if(_pitcherGamesG.isNotEmpty){
                        for(var game in _pitcherGamesG){
                          _pitcherGamesS.add((game.team + ': '+ game.mm + '/' + game.dd));
                        }
                      }


                      print(_pitcherGamesS);

                      _calcCombo(_currentPitcher);
                      
                    });
                  },
                  items: _Pitchers.map((String item) =>
                  DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
                )
              ),

              //Date Display
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 50, width: 175, off1: dellySkellys.width - 450, off2: 118),
                child: Row(
                  children: [
                    Text(
                      month + ' / ' + day + ' / ' + year,
                      style: TextStyle(
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
                  onChanged: (List<String> x) {
                    setState(() {
                      selected = x;

                      print(x);
                      _currentPitches = [];
                      for(var entry in x){

                        if(entry == 'FBs'){
                          //print(_pitchPlayer[_Pitchers.indexOf(_currentPitcher)].getCertPitches(entry));
                          _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].getCertPitches('FB');
                          _currentPitches = _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].pitches_requested;
                          //print(_currentPitches.length);
                        }
                        //GameInstance game = _pitcherGamesG[_pitcherGamesS.indexOf(entry)];
                        //_currentPitches.addAll(game.pitches);
                      }
                      setState(() {});
                      _calcCombo(_currentPitcher);
                      
                    });
                  },
                  selectedValues: selected,
                  whenEmpty: 'History',
                  options: _pitcherGamesS,
                  decoration: InputDecoration(border: InputBorder.none,
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
              CustomSingleChildLayout(
                delegate: DellySkelly(widgetSize: dellySkellys, height: 500, width: 460, off1: (dellySkellys.width / 2) - 395, off2: (dellySkellys.height / 2) - 300),
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (TapDownDetails details){
                      Pitch pitch_info;
                      String pitchkind = "";
                      int spd = 0;
                      bool strike = false;
                      bool swing = false;
                      bool hit = false;
                      bool k_looking = false;
                      bool k_swinging = false;
                      bool walk = false;
                      bool hbp = false;
                      bool in_zone = false;
                      bool foul = false;
                      bool bip = false;
                      TextEditingController textController = TextEditingController();
                      Offset loc = details.localPosition;
                      isPType = List.filled(4, false);
                      isPAction = List.filled(8, false);
                    
                      //Checks to see if pitch is a strike soley based on location
                      if(details.localPosition.dx > 105 && details.localPosition.dx < 370){
                        if(details.localPosition.dy > 18 && details.localPosition.dy < 320){
                          strike = true;
                          in_zone = true;
                          //print("Strike");
                        }
                      }
                      //Creates the popup and enables information input
                      if(current_mode == "Charting"){
                      var ret2 = showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Pitch Information"),
                            content: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState){
                              return Container(
                                height: 500,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pitch Type'),
                                    SizedBox(height: 5),
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
                                      children: PTypes,
                                      isSelected: isPType,
                                      onPressed: (int index) {
                                      setState(() {
                                        for (int i = 0; i < isPType.length; i++) {
                                          isPType[i] = i == index;
                                          if (index == 0){pitchkind = "FB";}
                                          else if(index == 1){pitchkind = "CB";}
                                          else if(index == 2){pitchkind = "CH";}
                                          else if(index == 3){pitchkind = "SL";}
                                        }
                                      });
                                    },
                                    ),
                                    SizedBox(height: 15),
                                    Text('Speed: '),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: textController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        helperText: "Enter Speed",
                                        constraints: BoxConstraints(
                                          maxWidth: 125,
                                          maxHeight: 35,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height:15),

                                    //Determines if anything happened during Pitch
                                    Text("Action"),
                                    SizedBox(height: 10),
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
                                      children: PActions,
                                      isSelected: isPAction,
                                      onPressed: (int index) {
                                        setState(() {
                                          if(index == 0){isPAction = [!swing, false, false, false, false, false, false, false];}
                                          if(index == 1){isPAction = [!swing, !foul, false, false, false, false, false, false];}
                                          if(index == 2){isPAction = [!swing, false, !hit, false, false, false, false, !bip];}
                                          if(index == 3){isPAction = [false, false, false, !walk, false, false, false, false];}
                                          if(index == 4){isPAction = [false, false, false, false, !hbp, false, false, false];}
                                          if(index == 5){isPAction = [!swing, false, false, false, false, !k_swinging, false, false];}
                                          if(index == 6){isPAction = [false, false, false, false, false, false, !k_looking, false];}
                                          if(index == 7){isPAction = [!swing, false, false, false, false, false, false, !bip];}
                                          swing = isPAction[0];
                                          hit = isPAction[2];
                                          walk = isPAction[3];
                                          hbp = isPAction[4];
                                          k_swinging = isPAction[5];
                                          k_looking = isPAction[6];
                                          foul = isPAction[1];
                                          bip = isPAction[7];
                                          if(swing || k_looking){strike = true;}
                                          

                                        });
                                        },
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
                                onPressed: () => {if(textController.text.isEmpty){spd = 0} else{spd = int.parse(textController.text)},
                                  pitch_info = Pitch(pitchkind, spd, strike, swing, hit, k_looking, k_swinging, hbp, walk, loc, in_zone, current_count, foul, bip),
                                   _cPitchLocations.add(pitch_info.location), 
                                   _pitchPlayer[_Pitchers.indexOf(_currentPitcher)].total_pitches.add(pitch_info),
                                   _calcCombo(_currentPitcher), print(_currentPitches), 
                                   print('Count: ' + current_count.item1.toString() + ', ' + current_count.item2.toString()), 
                                   print("Pitch Count: " + _pitch_count.toString()), 
                                  print(_pitchPlayer[_Pitchers.indexOf(_currentPitcher)].total_pitches),
                                  Navigator.pop(context)}, 
                                child: const Text('Confirm')
                              ),        
                            ],
                          );
                          }
                        );
                      }
                      
                    
                    },
                    child: RepaintBoundary(
                      child: DottedBorder(
                        color: Colors.black,
                        dashPattern: const [1, 3],
                        strokeWidth: 4,
                          child: current_mode == "Viewing" ?
                          CanvasTouchDetector(
                            builder: (context) => CustomPaint(
                              painter: paintPitch(_currentPitches, context, current_mode),
                              child: Container(
                                color: Colors.transparent,
                                height: 500,
                                width: 460,
                              ),
                            ),
                          )
                          :
                          CustomPaint(
                            painter: paintPitch(_currentPitches, context, current_mode),
                            child: Container(
                              color: Colors.transparent,
                              height: 500,
                              width: 460,
                            ),
                          )
                    ),
                  ),
                ),
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
                            Text("Pitch Count: " + _pitch_count.toString(), style: TextStyle(fontSize: 18)),
                            Text("Strike %: " + _strikePercentage.toStringAsFixed(0), style: TextStyle(fontSize: 18)),
                            Text("Ks: " + _numKs.toString(), style: TextStyle(fontSize: 18)),
                            Text("Hits: " + _numHits.toString(), style: TextStyle(fontSize: 18)),
                            Text("BBs: " + _numWalks.toString(), style: TextStyle(fontSize: 18)),
                            Text("HBPs: " + _numHBP.toString(), style: TextStyle(fontSize: 18))
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
                            Text("FB avg: " + _fb_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("FB S%: " + _fbSP.toStringAsFixed(2), style: TextStyle(fontSize: 15)),
                            Text(_fb_min.toStringAsFixed(2) + " -- " + _fb_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text("CB avg: " + _cb_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("CB S%: " + _cbSP.toStringAsFixed(2), style: TextStyle(fontSize: 15)),
                            Text(_cb_min.toStringAsFixed(2) + " -- " + _cb_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text("CH avg: " + _ch_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("CH S%: " + _chSP.toStringAsFixed(2), style: TextStyle(fontSize: 15)),
                            Text(_ch_min.toStringAsFixed(2) + " -- " + _ch_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text("SL avg: " + _sl_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("SL S%: " + _slSP.toStringAsFixed(2), style: TextStyle(fontSize: 15)),
                            Text(_sl_min.toStringAsFixed(2) + " -- " + _sl_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text(''),
                            
                            Text("In 0-0 Counts: " + _start.toString()),
                            Text("1-0: " + _start2ball.toStringAsFixed(2) + "%, 0-1: " + _start2strike.toStringAsFixed(2) + "%"),

                            Text("In 1-0 Counts: " + _1b0s.toString()),
                            Text("2-0: " + _1ball2ball.toStringAsFixed(2) + "%, 1-1: " + _1ball2strike.toStringAsFixed(2) + "%"),

                            Text("In 0-1 Counts: " + _0b1s.toString()),
                            Text("1-1: " + _1strike2ball.toStringAsFixed(2) + "%, 0-2: " + _1strike2strike.toStringAsFixed(2) + "%"),

                            Text("In 1-1 Counts: " + _even.toString()),
                            Text("2-1: " + _even2ball.toStringAsFixed(2) + "%, 1-2: " + _even2strike.toStringAsFixed(2) + "%"),

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
                            Text('Count', style: TextStyle(fontSize: 20)),
                            Text(current_count.item1.toString() + " - " + current_count.item2.toString(),
                              style: TextStyle(fontSize: 20))],
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

