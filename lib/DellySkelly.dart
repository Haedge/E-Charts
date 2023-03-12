//Skeleton For Delegates to reduce file #

// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';

class DellySkelly extends SingleChildLayoutDelegate {
      // You can pass any parameters to this class because you will instantiate your delegate
      // in the build function where you place your CustomMultiChildLayout.
      // I will use an Offset for this simple example.

  DellySkelly({required this.widgetSize, required this.height, required this.width, required this.off1, required this.off2});

  final Size widgetSize;
  final double height;
  final double width;
  final double off1;
  final double off2;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints){
    return BoxConstraints.expand(
      height: height,
      width: width,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize){
    return Offset(off1, off2);
  }
  @override
  bool shouldRelayout(DellySkelly oldDelegate) {
    return widgetSize != oldDelegate.widgetSize;
  }
}