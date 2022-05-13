// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:touchable/touchable.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Chart App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Pitch> _totalpitches = [];
  int _pitch_count = 0;
  double _fb_avg = 0;
  int _fb_min = 0;
  int _fb_max = 0;
  double _ch_avg = 0;
  int _ch_min = 0;
  int _ch_max = 0;
  double _cb_avg = 0;
  int _cb_min = 0;
  int _cb_max = 0;
  double _sl_avg = 0;
  int _sl_min = 0;
  int _sl_max = 0;
  int _numHits = 0;
  int _numWalks = 0;
  int _numHBP = 0;
  int _numKs = 0;
  double _strikePercentage = 0;
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  final List<String> _Pitchers = ['Pitchers','Andrei Stoyanow', 'Bobby Fowler', 'Brody Plemmons', 'Cade McWilliams', 'Connor Stack', 'David Blackburn',
                                  'Ethan Thomas', 'Gunner Hopkins', 'Hogan Ralston', 'Jack Hodgins', 'Jackson Corrigan', 'Jacob Wagner', 'John Henry Fowler', 
                                  'John Schaller', 'Johnny Miles', 'Kyle Poissoit', 'Kyle Wellman', 'Miles Schluterman', 'Nathan Silva', 'Patrick Chastain', 
                                  'Ryan Torres', 'Teddy Olander', 'Tyler Meek', 'Tyler Wilson', 'Will Graves', 'Zach Orlando'];
  String _currentPitcher = "Pitcher";
  final TextEditingController _moText = TextEditingController();
  final TextEditingController _dayText = TextEditingController();
  final TextEditingController _yrText = TextEditingController();
  String _currentTeam = "Team";
  final List<String> _Teams = ['Team', 'Belhaven', 'Berry','BSC', 'CBC', 'Centre', 'Dallas', 'Depauw', 'Millsaps', 'Nebraska', 'Oglethorpe', 'Ozarks', 'Rhodes',
                                'St Thomas','Scrimmage','Sewanee'];


//Trying to figure out
  void _resetChart(){
    _totalpitches = [];
    _pitch_count = 0;
    _fb_avg = 0;
    _fb_min = 0;
    _fb_max = 0;
    _ch_avg = 0;
    _ch_min = 0;
    _ch_max = 0;
    _cb_avg = 0;
    _cb_min = 0;
    _cb_max = 0;
    _sl_avg = 0;
    _sl_min = 0;
    _sl_max = 0;
    _numHits = 0;
    _numWalks = 0;
    _numHBP = 0;
    _numKs = 0;
    _strikePercentage = 0;

    _calculateInfo();

  }

  _newChart(){

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset Chart?'),
        actionsPadding: EdgeInsets.only(top: 15, left: 35),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("Yes"),
            onPressed: () => {_resetChart, print("NewChart"), Navigator.pop(context)},
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
            )
        ]
      )
      );
    
    
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




  //Popup to get pitch information
  _newPitch(TapDownDetails details){

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
    TextEditingController textController = TextEditingController();
    Offset loc = details.localPosition;


    //Checks to see if pitch is a strike soley based on location
    if(details.localPosition.dx > 105 && details.localPosition.dx < 370){
      if(details.localPosition.dy > 18 && details.localPosition.dy < 320){
        strike = true;
        //print("Strike");
      }
    }

    //Creates the popup and enables information input
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pitch Information'),
        actionsPadding: EdgeInsets.only(top: 15, left: 35),
        actions: <Widget>[

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
            Text(
              'Pitch Type',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ],
          ),
          //Decides the what pitch was thrown
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => {pitchkind = "FB"},
                child: const Text('FB'),
              ),
              ElevatedButton(
                onPressed: () => {pitchkind = "CB"},
                child: const Text('CB'),
              ),
              ElevatedButton(
                onPressed: () => {pitchkind = "CH"},
                child: const Text('CH'),
              ),
              ElevatedButton(
                onPressed: () => {pitchkind = "SL"},
                child: const Text('SL'),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
            Text(
              'Speed:',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ],
          ),

          //Spacing
          Text(''),

          //Inut for Speed
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Text('  '),
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
            ],
          ),

          //Spacing
          Text(''),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
            Text(
              'Action:',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ],
          ),
          
          //Determines if anything happened during Pitch
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => {swing = true, strike = true, walk = false, hit = false, hbp = false, k_swinging = false, k_looking = false},
                child: const Text('Swing'),
              ),
              ElevatedButton(
                onPressed: () => {walk = true, strike = false, hit = false, k_looking = false, k_swinging = false, swing = false, hbp = false},
                child: const Text('Walk'),
              ),
              ElevatedButton(
                onPressed: () => {hit = true, strike = true, swing = true, walk = false, hbp = false, k_swinging = false, k_looking = false},
                child: const Text('Hit'),
              ),
              ElevatedButton(
                onPressed: () => {hbp = true, strike = false, hit = false, k_looking = false, k_swinging = false, swing = false, walk = false},
                child: const Text('HBP'),
              ),
              ElevatedButton(
                onPressed: () => {k_swinging = true, strike = true, walk = false, hit = false, hbp = false, swing = true, k_looking = false},
                child: const Text('K swinging'),
              ),
              ElevatedButton(
                onPressed: () => {k_looking = true, strike = true, walk = false, hit = false, hbp = false, swing = false, k_swinging = false},
                child: const Text('K looking'),
              ),
              ElevatedButton(
                onPressed: () => {swing = true, strike = true, walk = false, hit = false, hbp = false, k_swinging = false, k_looking = false},
                child: const Text('Foul')
              ),
            ],
          ),

          //On pressed, checks to see if speed is available, if not, sets to 0, 
          //then creates a Pitch using the information gathered from buttons, increments pitch_count
          ElevatedButton(
            onPressed: () => { if(textController.text.isEmpty){spd = 0}, if(textController.text.isNotEmpty){spd = int.parse(textController.text)},
              pitch_info = new Pitch(pitchkind, spd, strike, swing, hit, k_looking, k_swinging, hbp, walk, loc),_totalpitches.add(pitch_info), _pitch_count += 1, 
              print(_totalpitches), if(hit){_numHits += 1}, if(walk){_numWalks += 1}, if(hbp){_numHBP += 1}, if(k_looking|| k_swinging){_numKs += 1}, 
              print("Pitch Count: " + _pitch_count.toString()), _calculateInfo(), Navigator.pop(context, 'OK')}, 
            child: const Text('Confirm')
          ),
        ],
      ),
    );
    //Here is where it says Offset(x, y)
    //print("x: " + details.localPosition.dx.toString() + " , y:" + details.localPosition.dy.toString());

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

    }

    //Updates and calculates the values for the widgets
    setState((){
      if(fb_count != 0){
        _fb_avg = fb_speed_tot / fb_count;
        _fb_min = fb_speeds.reduce(min);
        _fb_max = fb_speeds.reduce(max);
      }
    

      if(ch_count != 0){
        _ch_avg = ch_speed_tot / ch_count;
        _ch_min = ch_speeds.reduce(min);
        _ch_max = ch_speeds.reduce(max);
      }

      if(cb_count != 0){
        _cb_avg = cb_speed_tot / cb_count;
        _cb_min = cb_speeds.reduce(min);
        _cb_max = cb_speeds.reduce(max);
      }

      if(sl_count != 0){
        _sl_avg = sl_speed_tot / sl_count;
        _sl_min = sl_speeds.reduce(min);
        _sl_max = sl_speeds.reduce(max);
      }

      _strikePercentage = (strike_count / _pitch_count) * 100;
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

    return new Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: _printKey,
          child:
            Stack(
              children: <Widget>[
                new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(image: new AssetImage("assets/images/new_Chart.png"),),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  FloatingActionButton(
                  child: const Icon(Icons.download),
                  onPressed: _printScreen,
                  ),
                  /*
                  FloatingActionButton(
                    onPressed: _newChart,
                    child: const Text("Reset"),
                  ),
                  */
                ]
              ),

              //Pitcher Dropdown
              CustomSingleChildLayout(
                delegate: _PitchersDelegate(widgetSize: MediaQuery.of(context).size),
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
                delegate: _DateDelegate(widgetSize: MediaQuery.of(context).size),
                child: Row(
                  children: [
                    TextField(
                      controller: _moText,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        helperText: "MM",
                        constraints: BoxConstraints(
                          maxWidth: 50,
                          maxHeight: 35,
                        ),
                      ),
                    ),

                    Text("/"),

                    TextField(
                      controller: _dayText,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        helperText: "DD",
                        constraints: BoxConstraints(
                          maxWidth: 50,
                          maxHeight: 35,
                        ),
                      ),
                    ),

                    Text("/"),

                    TextField(
                      controller: _yrText,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        helperText: "YR",
                        constraints: BoxConstraints(
                          maxWidth: 50,
                          maxHeight: 35,
                        ),
                      ),
                    ),

                  ],
                )
              ),

              //Team Dropdown
              CustomSingleChildLayout(
                delegate: _TeamDelegate(widgetSize: MediaQuery.of(context).size),
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
                delegate: _StrikezoneDelegate(widgetSize: strikezone_size),
                child: GestureDetector(
                    onTapDown: (TapDownDetails details){
                      _newPitch(details);
                    },
                    child: RepaintBoundary(
                      child: DottedBorder(
                        color: Colors.black,
                        dashPattern: const [1, 3],
                        strokeWidth: 4,
                          child: CustomPaint(
                            painter: _paintPitch(_totalpitches),
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
                delegate: _OutingDelegate(widgetSize: outing_box),
                  child:
                    new DottedBorder(
                      color: Colors.black,
                      dashPattern: const [1, 3],
                      strokeWidth: 0,
                      child: Container(
                        height: 200,
                        width: 200,
                        child: new Column(
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
                delegate: _InfoBoxDelegate(widgetSize: info_box),
                  child:
                    new DottedBorder(
                      color: Colors.black,
                      dashPattern: const [1, 3],
                      strokeWidth: 1,
                      child: Container(
                        height: 275,
                        width: 200,
                        child: new Column(
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

class _paintPitch extends CustomPainter{
  List<Pitch> pitches;

  _paintPitch(this.pitches);
  

  @override
  void paint(Canvas canvas, Size size){
      

    for(Pitch pitch in pitches){

      Paint paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;


      //If a swing, then fill the shape
      if(pitch.swing){
          paint.style = PaintingStyle.fill;
        }

      // Fastball Shape
      if(pitch.type == "FB"){
        Rect fb = Rect.fromCenter(center: pitch.location, width: 12, height: 12);
        canvas.drawRect(fb, paint);
      }

      //Curveball Shape
      if(pitch.type == "CB"){
        var cb = Path();
        cb.moveTo(pitch.location.dx, pitch.location.dy - 6);
        cb.lineTo(pitch.location.dx + 7.5, pitch.location.dy + 10);
        cb.lineTo(pitch.location.dx - 7.5, pitch.location.dy + 10);
        cb.lineTo(pitch.location.dx, pitch.location.dy - 7);
        canvas.drawPath(cb, paint);
      }

      //Change Up Shape
      if(pitch.type == "CH"){
        canvas.drawCircle(pitch.location, 7.5, paint);
      }

      //Slider Shape
      if(pitch.type == "SL"){
        var sl = Path();
        sl.moveTo(pitch.location.dx - 6, pitch.location.dy - 6);
        sl.lineTo(pitch.location.dx + 6, pitch.location.dy - 6);
        sl.lineTo(pitch.location.dx + 9, pitch.location.dy);
        sl.lineTo(pitch.location.dx + 6, pitch.location.dy + 6);
        sl.lineTo(pitch.location.dx - 6, pitch.location.dy + 6);
        sl.lineTo(pitch.location.dx - 9, pitch.location.dy);
        sl.lineTo(pitch.location.dx - 6, pitch.location.dy - 7);
        canvas.drawPath(sl, paint);
      }

    }
  }
  @override
  bool shouldRepaint(_paintPitch oldDelegate) => true;
}

//Pitch class, this will hold the information of each individual pitch
class Pitch{
  String type = "";
  int speed = 0;
  bool strike = false;
  bool swing = false;
  bool hit = false;
  bool k_looking = false;
  bool k_swinging = false;
  bool hbp = false;
  bool bb = false;
  Offset location = Offset.zero;

  Pitch(String type, int speed, bool strike, bool swing, bool hit, bool k_looking, bool k_swinging, bool hbp, bool bb, Offset location){
    this.type = type;
    this.speed = speed;
    this.strike = strike;
    this.swing = swing;
    this.hit = hit;
    this.k_looking = k_looking;
    this.k_swinging = k_swinging;
    this.hbp = hbp;
    this.bb = bb;
    this.location = location;
  }


}


class Player{
  String name = "";
  double strike_percentage = 0.0;
  int walks = 0;
  int hits = 0;
  int pitch_count = 0;

  //Input only being pitcher name and pitch?
  Player(String name, double strike_percentage, int walks, int hits, int pitch_count){
    this.name = name;
    this.strike_percentage = strike_percentage;
    this.walks = walks;
    this.hits = hits;
    this.pitch_count = pitch_count;
  }
}

//Layout for Strikezone
class _StrikezoneDelegate extends SingleChildLayoutDelegate {
      // You can pass any parameters to this class because you will instantiate your delegate
      // in the build function where you place your CustomMultiChildLayout.
      // I will use an Offset for this simple example.

  _StrikezoneDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 500,
      width: 460,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width / 2) - 395, (widgetSize.height / 2) - 300);
  }
  @override
  bool shouldRelayout(_StrikezoneDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}

//Layout for InfoBox
class _InfoBoxDelegate extends SingleChildLayoutDelegate {

  _InfoBoxDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 275,
      width: 200,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 315, (widgetSize.height) - 500);
  }
  @override
  bool shouldRelayout(_InfoBoxDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}

//Layout for Outing Box
class _OutingDelegate extends SingleChildLayoutDelegate {

  _OutingDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 175,
      width: 150,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 200, 300);
  }
  @override
  bool shouldRelayout(_OutingDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}

//Layout for Pitcher
class _PitchersDelegate extends SingleChildLayoutDelegate {

  _PitchersDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 50,
      width: 175,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 425, 70);
  }
  @override
  bool shouldRelayout(_PitchersDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}

//Layout for Date
class _DateDelegate extends SingleChildLayoutDelegate {

  _DateDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 50,
      width: 175,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 445, 130);
  }
  @override
  bool shouldRelayout(_DateDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}

class _TeamDelegate extends SingleChildLayoutDelegate {

  _TeamDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 50,
      width: 120,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 370, 170);
  }
  @override
  bool shouldRelayout(_TeamDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}