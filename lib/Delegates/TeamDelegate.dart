// ignore_for_file: file_names

import 'package:flutter/material.dart';


class TeamDelegate extends SingleChildLayoutDelegate {

  TeamDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    // ignore: prefer_const_constructors
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
  bool shouldRelayout(TeamDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}