// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:my_app/HomePage.dart';

void main() => runApp(eCharts());

class eCharts extends StatelessWidget {
  const eCharts({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(title: 'Chart App'),
    );
  }
}