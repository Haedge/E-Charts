// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';

class OutingDelegate extends SingleChildLayoutDelegate {

  OutingDelegate({required this.widgetSize});

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
  bool shouldRelayout(OutingDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}