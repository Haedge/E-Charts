// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable, constant_identifier_names, file_names

import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/rendering.dart';
import 'package:my_app/Delegates/CountDelegate.dart';
import 'package:my_app/Delegates/GameDelegate.dart';
import 'package:my_app/database_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'Baseball_Pieces/Player.dart';
import 'Delegates/TeamDelegate.dart';
import 'Delegates/DateDelegate.dart';
import 'Delegates/PitchersDelegate.dart';
import 'Delegates/OutingDelegate.dart';
import 'Delegates/InfoBoxDelegate.dart';
import 'Delegates/StrikeZoneDelegate.dart';
import 'Baseball_Pieces/Pitch.dart';
import 'Baseball_Pieces/paintPitch.dart';
import 'HomePage.dart';
import 'GameInstance.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:touchable/touchable.dart';


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
  Text('Walk'),
  Text('HBP'),
  Text('K Swinging'),
  Text('K Looking')
];



class eCharts extends State<HomePage> {

  List<Pitch> _currentPitches = [];
  List<Offset> _cPitchLocations = [];
  int _pitch_count = 0;
  double _fb_avg = 0; int _fb_min = 0; int _fb_max = 0;
  double _ch_avg = 0; int _ch_min = 0; int _ch_max = 0;
  double _cb_avg = 0; int _cb_min = 0; int _cb_max = 0;
  double _sl_avg = 0; int _sl_min = 0; int _sl_max = 0;
  int _numHits = 0; int _numWalks = 0; int _numHBP = 0;
  int _numKs = 0; double _strikePercentage = 0;


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
  final List<String> _Pitchers = [' ', 'Andrei Stoyanow', 'Bobby Fowler', 'Brody Plemmons', 'Cade McWilliams', 'Connor Stack', 'David Blackburn',
                                  'Ethan Thomas', 'Gunner Hopkins', 'Hogan Ralston', 'Jack Hodgins', 'Jackson Corrigan', 'Jacob Wagner', 'John Henry Fowler', 
                                  'John Schaller', 'Johnny Miles', 'Kyle Poissoit', 'Miles Schluterman', 'Nathan Silva', 'Patrick Chastain', 
                                  'Ryan da best eva Torres', 'Teddy Olander', 'Tyler Meek', 'Aiden Leggit', 'Brax Waller', 'Bryson Bales', 'Caleb Ougel',
                                  'Chance Reed', 'Chase Nials', 'JD Nichols', 'Kyler Oathout', 'Matthew Mitchell', 'Miko Djuric', 'Nate Hirsh',
                                  'Nic?', 'Sam Collier', 'Trent Jordan', 'Tucker Isbell', 'William Klueber', 'Wyatt Goodman', 'Zane Nolan',
                                  'Ian Guthrie'];
  
  String _gameHist = " ";


  String _currentPitcher = " ";
  TextEditingController _moText = TextEditingController();
  TextEditingController _dayText = TextEditingController();
  TextEditingController _yrText = TextEditingController();
  String _currentTeam = " ";
  final List<String> _Teams = [' ', 'Belhaven', 'Berry','BSC', 'CBC', 'Centre', 'Dallas', 'Depauw', 'Millsaps', 'Nebraska', 'Oglethorpe', 'Ozarks', 'Rhodes',
                                'St Thomas','Scrimmage','Sewanee', 'Bullpen'];
  List<bool> isPType = List.filled(4, false);
  List<bool> isPAction = List.filled(7, false);

  List<Player> _pitchPlayer = [];

  
  getGames(Player pitcher){
    if(pitcher.games == null){
      return [];
    } else {
      return pitcher.games;
    }
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

  _reset(){
    _currentPitches = [];
    _cPitchLocations = [];
    _numHBP = 0; _numHits = 0; _numKs = 0; _numWalks = 0; _pitch_count = 0;
    _strikePercentage = 0;
    _fb_avg = 0; _fb_min = 0; _fb_max = 0;
    _ch_avg = 0; _ch_min = 0; _ch_max = 0;
    _cb_avg = 0; _cb_min = 0; _cb_max = 0;
    _sl_avg = 0; _sl_min = 0; _sl_max = 0;
    _calculateCountPerc();
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


  _createInstance(Player pitcher, List<Pitch> pitches, String mm, String dd, int game_n, String team){
    GameInstance game = GameInstance(pitches, pitcher, team, game_n, mm, dd);
    pitcher.addGame(pitcher, game);
  }


  _undoPitch(){
    if (_currentPitches.isNotEmpty){
      _currentPitches.removeLast();
      _cPitchLocations.removeLast();
      _calculateInfo();
      _calculateCountPerc();
      print(_currentPitches.length);
      print(_currentPitches.length - 1);
      if(_currentPitches.isNotEmpty){
        _calculateCount(_currentPitches[_currentPitches.length - 1]);
      }
      setState(() {});
    }
  }

  _calculateCountPerc(){

    _stb = 0; _sts = 0; 
    _1bts = 0; _1btb = 0;
    _1stb = 0; _1sts = 0;
    _start = 0; _1b0s = 0;
    _0b1s = 0; 
    _1b1sts = 0; _1b1stb = 0;
    _even = 0;
    int totps = _currentPitches.length;

    for(Pitch pitch in _currentPitches){
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

    if(prev_pitch.hit){
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
  _calculateInfo(){
    int fb_count = 0;
    int fb_speed_tot = 0;
    List<int> fb_speeds = [];
    int ch_count = 0;
    int ch_speed_tot = 0;
    List<int> ch_speeds = [];
    int cb_count = 0;
    int cb_speed_tot = 0;
    List<int> cb_speeds = [];
    int sl_count = 0;
    int sl_speed_tot = 0;
    List<int> sl_speeds = [];
    int strike_count = 0;
    _numHBP = 0; _numHits = 0;
    _numKs = 0; _numWalks = 0;



    //Goes through all pitches in the pitch array
    for(Pitch entry in _currentPitches){
      String p_type = entry.type;
      int p_spd = entry.speed;
      bool p_strike = entry.strike;

      //Gathers pitch information based on type
      if(p_type == "FB"){
        if(p_spd != 0){
          fb_count += 1;
          fb_speed_tot += p_spd;
          fb_speeds.add(p_spd);
        }
      }else if(p_type == "CH"){
        if(p_spd != 0){
          ch_count += 1;
          ch_speed_tot += p_spd;
          ch_speeds.add(p_spd);
        }
      }else if(p_type == "CB"){
        if(p_spd != 0){
          cb_count += 1;
          cb_speed_tot += p_spd;
          cb_speeds.add(p_spd);
        }
      } else if(p_type == "SL"){
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
      if(fb_count != 0){
        _fb_avg = fb_speed_tot / fb_count;
        _fb_min = fb_speeds.reduce(min);
        _fb_max = fb_speeds.reduce(max);
      } else {
        _fb_avg = 0; _fb_min = 0; _fb_max = 0;
      }
    

      if(ch_count != 0){
        _ch_avg = ch_speed_tot / ch_count;
        _ch_min = ch_speeds.reduce(min);
        _ch_max = ch_speeds.reduce(max);
      } else {
        _ch_avg = 0; _ch_min = 0; _ch_max = 0;
      }

      if(cb_count != 0){
        _cb_avg = cb_speed_tot / cb_count;
        _cb_min = cb_speeds.reduce(min);
        _cb_max = cb_speeds.reduce(max);
      } else {
        _cb_avg = 0; _cb_min = 0; _cb_max = 0;
      }

      if(sl_count != 0){
        _sl_avg = sl_speed_tot / sl_count;
        _sl_min = sl_speeds.reduce(min);
        _sl_max = sl_speeds.reduce(max);
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

//The Program
  @override
  Widget build(BuildContext context) {
    Size strikezone_size = MediaQuery.of(context).size;
    Size info_box = MediaQuery.of(context).size;
    Size outing_box = MediaQuery.of(context).size;
    Size count_box = MediaQuery.of(context).size;
    Offset _location = Offset(0, 0);
    String dropDownValue = 'Pitcher';
    String dropDownTeam = 'Team';
    // Added sort here, might not work because of this
    _Pitchers.sort();
    _Teams.sort();
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String year = DateTime.now().year.toString();


    for(String pitcher in _Pitchers){
      _pitchPlayer.add(Player(name: pitcher));
    }

    return Scaffold(
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
                                    _reset(),
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
                              ElevatedButton(onPressed: () => {_undoPitch(), Navigator.pop(context)}, child: Text('Confirm')),
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
                delegate: PitchersDelegate(widgetSize: MediaQuery.of(context).size),
                child: DropdownButton<String>(
                  value: _currentPitcher,
                  onChanged: (String? newValue) {
                    setState(() {
                      _currentPitcher = newValue!;
                      print(_currentPitcher);
                    });
                  },
                  items: _Pitchers.map((String item) =>
                  DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
                )
              ),

              //Date Display
              CustomSingleChildLayout(
                delegate: DateDelegate(widgetSize: MediaQuery.of(context).size),
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

              CustomSingleChildLayout(delegate: GameDelegate(widgetSize: MediaQuery.of(context).size),
                child: DropdownButton<String>(
                  value: _gameHist,
                  onChanged: (String? newValue){
                    setState((){
                      _gameHist = newValue!;
                    });
                  },
                  //Place holder
                  items: _Teams.map((String item) =>
                  DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
                )

              ),

              //Team Dropdown
              CustomSingleChildLayout(
                delegate: TeamDelegate(widgetSize: MediaQuery.of(context).size),
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
                delegate: StrikeZoneDelegate(widgetSize: strikezone_size), 
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
                      TextEditingController textController = TextEditingController();
                      Offset loc = details.localPosition;
                      isPType = List.filled(4, false);
                      isPAction = List.filled(7, false);
                    
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
                                          if(index == 0){isPAction = [true, false, false, false, false, false, false];}
                                          if(index == 1){isPAction = [true, true, false, false, false, false, false];}
                                          if(index == 2){isPAction = [true, false, true, false, false, false, false];}
                                          if(index == 3){isPAction = [false, false, false, true, false, false, false];}
                                          if(index == 4){isPAction = [false, false, false, false, true, false, false];}
                                          if(index == 5){isPAction = [true, false, false, false, false, true, false];}
                                          if(index == 6){isPAction = [false, false, false, false, false, false, true];}
                                          swing = isPAction[0];
                                          hit = isPAction[2];
                                          walk = isPAction[3];
                                          hbp = isPAction[4];
                                          k_swinging = isPAction[5];
                                          k_looking = isPAction[6];
                                          foul = isPAction[1];
                                          if(swing || k_swinging || k_looking){strike = true;}

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
                                  pitch_info = Pitch(pitchkind, spd, strike, swing, hit, k_looking, k_swinging, hbp, walk, loc, in_zone, current_count, foul),
                                  _currentPitches.add(pitch_info), _cPitchLocations.add(pitch_info.location), _calculateInfo(), _calculateCount(pitch_info), _calculateCountPerc(),
                                  print(_currentPitches), print('Count: ' + current_count.item1.toString() + ', ' + current_count.item2.toString()), print("Pitch Count: " + _pitch_count.toString()), 
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
                delegate: OutingDelegate(widgetSize: outing_box),
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
                delegate: InfoBoxDelegate(widgetSize: info_box),
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
                            Text("FB range: ", style: TextStyle(fontSize: 18)),
                            Text(_fb_min.toStringAsFixed(2) + " -- " + _fb_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text("CB avg: " + _cb_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("CB range: ", style: TextStyle(fontSize: 18)),
                            Text(_cb_min.toStringAsFixed(2) + " -- " + _cb_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text("CH avg: " + _ch_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("CH range: ", style: TextStyle(fontSize: 18)),
                            Text(_ch_min.toStringAsFixed(2) + " -- " + _ch_max.toStringAsFixed(2), style: TextStyle(fontSize: 15)),

                            Text("SL avg: " + _sl_avg.toStringAsFixed(2), style: TextStyle(fontSize: 18)),
                            Text("SL range: ", style: TextStyle(fontSize: 18)),
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
                  delegate: CountDelegate(widgetSize: count_box),
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

