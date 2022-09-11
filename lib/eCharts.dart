// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable, constant_identifier_names, file_names

import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'Baseball_Pieces/Player.dart';
import 'Delegates/TeamDelegate.dart';
import 'Delegates/DateDelegate.dart';
import 'Delegates/PitchersDelegate.dart';
import 'Delegates/OutingDelegate.dart';
import 'Delegates/InfoBoxDelegate.dart';
import 'Delegates/StrikeZoneDelegate';
import 'Baseball_Pieces/Pitch.dart';
import 'Baseball_Pieces/paintPitch.dart';
import 'HomePage.dart';
import 'GameInstance.dart';

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
  List<Pitch> _totalpitches = [];
  int _pitch_count = 0;
  double _fb_avg = 0; int _fb_min = 0; int _fb_max = 0;
  double _ch_avg = 0; int _ch_min = 0; int _ch_max = 0;
  double _cb_avg = 0; int _cb_min = 0; int _cb_max = 0;
  double _sl_avg = 0; int _sl_min = 0; int _sl_max = 0;
  int _numHits = 0; int _numWalks = 0; int _numHBP = 0;
  int _numKs = 0; double _strikePercentage = 0;
  
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  final List<String> _Pitchers = [' ', 'Andrei Stoyanow', 'Bobby Fowler', 'Brody Plemmons', 'Cade McWilliams', 'Connor Stack', 'David Blackburn',
                                  'Ethan Thomas', 'Gunner Hopkins', 'Hogan Ralston', 'Jack Hodgins', 'Jackson Corrigan', 'Jacob Wagner', 'John Henry Fowler', 
                                  'John Schaller', 'Johnny Miles', 'Kyle Poissoit', 'Miles Schluterman', 'Nathan Silva', 'Patrick Chastain', 
                                  'Ryan Torres', 'Teddy Olander', 'Tyler Meek', 'Aiden Leggit', 'Brax Waller', 'Bryson Bales', 'Caleb Ougel',
                                  'Chance Reed', 'Chase Nials', 'JD Nichols', 'Kyler Oathout', 'Matthew Mitchell', 'Miko Djuric', 'Nate Hirsh',
                                  'Nic?', 'Sam Collier', 'Trent Jordan', 'Tucker Isbell', 'William Klueber', 'Wyatt Goodman', 'Zane Nolan',
                                  'Ian Guthrie'];
  

  String _currentPitcher = " ";
  TextEditingController _moText = TextEditingController();
  TextEditingController _dayText = TextEditingController();
  TextEditingController _yrText = TextEditingController();
  String _currentTeam = " ";
  final List<String> _Teams = [' ', 'Belhaven', 'Berry','BSC', 'CBC', 'Centre', 'Dallas', 'Depauw', 'Millsaps', 'Nebraska', 'Oglethorpe', 'Ozarks', 'Rhodes',
                                'St Thomas','Scrimmage','Sewanee'];
  List<bool> isPType = List.filled(4, false);
  List<bool> isPAction = List.filled(7, false);

  
  

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

  _reset(){
    _totalpitches = [];
    _numHBP = 0; _numHits = 0; _numKs = 0; _numWalks = 0; _pitch_count = 0;
    _strikePercentage = 0;
    _fb_avg = 0; _fb_min = 0; _fb_max = 0;
    _ch_avg = 0; _ch_min = 0; _ch_max = 0;
    _cb_avg = 0; _cb_min = 0; _cb_max = 0;
    _sl_avg = 0; _sl_min = 0; _sl_max = 0;
    setState(() {});
  }

  void _createInstance(Player pitcher, List<Pitch> pitches, String mm, String dd, int game_n, String team){
    GameInstance game = GameInstance(pitches, pitcher, team, game_n, mm, dd);
    pitcher.addGame(pitcher, game);
  }

  _undoPitch(){
    _totalpitches.removeLast();
    _calculateInfo();
    setState(() {});
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
    for(Pitch entry in _totalpitches){
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

      _pitch_count = _totalpitches.length;
      if(_pitch_count == 0){_strikePercentage = 0;}else{_strikePercentage = (strike_count / _pitch_count) * 100;}
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
    Offset _location = Offset(0, 0);
    String dropDownValue = 'Pitcher';
    String dropDownTeam = 'Team';
    // Added sort here, might not work because of this
    _Pitchers.sort();
    _Teams.sort();
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String year = DateTime.now().year.toString();
    

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
                                  onPressed: () => {
                                    //Add game method here
                                    Navigator.pop(context)
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
                  }, child: Icon(Icons.undo))
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

              //Date Input
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
                                pitch_info = Pitch(pitchkind, spd, strike, swing, hit, k_looking, k_swinging, hbp, walk, loc, in_zone),
                                _totalpitches.add(pitch_info), _calculateInfo(), print(_totalpitches), print("Pitch Count: " + _pitch_count.toString()), 
                                 Navigator.pop(context)}, 
                              child: const Text('Confirm')
                            ),        
                          ],
                        );
                        }
                      );
                    
                    },
                    child: RepaintBoundary(
                      child: DottedBorder(
                        color: Colors.black,
                        dashPattern: const [1, 3],
                        strokeWidth: 4,
                          child: CustomPaint(
                            painter: paintPitch(_totalpitches),
                            child: Container(
                              color: Colors.transparent,
                              height: 500,
                              width: 460,
                            ),
                          ),
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
                        height: 200,
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
                        height: 275,
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
                          ]
                        ),
                      ),
                    ),
                ),
                ]
          )
        )
      ),
    );
  }

}

