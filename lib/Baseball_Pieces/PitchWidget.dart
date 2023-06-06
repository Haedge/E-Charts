import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/eCharts.dart';
import 'package:my_app/Baseball_Pieces/paintPitch.dart';

class PitchWidget extends StatefulWidget{
  final List<Pitch> pitches;
  // final List<Pitch> updatePitches;

  const PitchWidget({
    Key? key,
    required this.pitches,
    // required this.updatePitches,
  }) : super(key : key);


  @override
  _PitchWidgetState createState() => _PitchWidgetState();
}


class _PitchWidgetState extends State<PitchWidget> {
  List<Pitch> currentPitches = [Pitch.fromMap({
        'type': 'FB',
        'spd': 88,
        'loc_x': 361.00, 'loc_y': 200.00,
        'oldCountBalls' : 0, 'oldCountStrikes': 0, 'strike': true,
        'swing': false, 'hit': false, 'K' : true, 'ꓘ' : false,
        'hbp': false, 'bb': false, 'in_zone': false, 'foul': false, 'bip': false
      })];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: paintPitch(widget.pitches, context, current_mode),
      child: Container(
        color: Colors.transparent,
        height: 500,
        width: 460,
      ),
    );
  }

  void updatePitchesInPitchWidget(List<Pitch> pitches) {
    setState(() {
      currentPitches = pitches;
    });
  }
}