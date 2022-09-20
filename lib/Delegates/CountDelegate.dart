// ignore_for_file: file_names
import 'package:flutter/material.dart';

class CountDelegate extends SingleChildLayoutDelegate {

  CountDelegate({required this.widgetSize});

  final Size widgetSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    // ignore: prefer_const_constructors
    return BoxConstraints.expand(
      height: 60,
      width: 75,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset((widgetSize.width) - 320, 300);
  }
  @override
  bool shouldRelayout(CountDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}