import 'package:flutter/material.dart';
import 'package:my_app/Baseball_Pieces/Pitch.dart';
import 'package:my_app/eCharts.dart';
import 'package:my_app/Baseball_Pieces/paintPitch.dart';
import 'package:my_app/Baseball_Pieces/paintHeatmap.dart';

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
  List<Pitch> currentPitches = [];

  @override
  Widget build(BuildContext context) {
    return isHeatmapMode ? buildHeatMap() : buildChartView();
  }

  Widget buildChartView(){
    return CustomPaint(
      painter: paintPitch(widget.pitches, context, current_mode),
      child: Container(
        color: Colors.transparent,
        height: 500,
        width: 460,
      ),
    );
  }

  Widget buildHeatMap(){
    return CustomPaint(
      painter: paintHeatmap(widget.pitches, context, current_mode),
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