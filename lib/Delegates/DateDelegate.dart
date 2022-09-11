// ignore_for_file: file_names
import 'package:flutter/material.dart';

class DateDelegate extends SingleChildLayoutDelegate {

  DateDelegate({required this.widgetSize});

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
    return Offset((widgetSize.width) - 445, 118);
  }
  @override
  bool shouldRelayout(DateDelegate oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}