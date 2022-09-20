// ignore_for_file: file_names
import 'package:flutter/material.dart';

class GameDelegate extends SingleChildLayoutDelegate {

  GameDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    // ignore: prefer_const_constructors
    return BoxConstraints.expand(
      height: 50,
      width: 175,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 300, 118);
  }
  @override
  bool shouldRelayout(GameDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}