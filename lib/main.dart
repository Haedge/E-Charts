// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable

import 'dart:core';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/HomePage.dart';

import 'Baseball_Pieces/PitchWidget.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(eCharts());
  }

class eCharts extends StatelessWidget {
  const eCharts({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PitchWidget? pitchWidget;
    return MaterialApp(
      home: const HomePage(title: 'Chart App'),
    );
  }
}