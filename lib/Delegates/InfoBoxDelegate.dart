// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';

//Layout for InfoBox
class InfoBoxDelegate extends SingleChildLayoutDelegate {

  InfoBoxDelegate({required this.widgetSize});

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
  bool shouldRelayout(InfoBoxDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}