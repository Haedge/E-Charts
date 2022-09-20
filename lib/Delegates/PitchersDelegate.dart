// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';


class PitchersDelegate extends SingleChildLayoutDelegate {

  PitchersDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: 50,
      width: 204,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 425, 70);
  }
  @override
  bool shouldRelayout(PitchersDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}