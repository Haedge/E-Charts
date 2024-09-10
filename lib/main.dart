// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, camel_case_types, avoid_print, sized_box_for_whitespace, prefer_initializing_formals, non_constant_identifier_names, unused_local_variable

import 'dart:core';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/HomePage.dart';
import 'package:my_app/dataProvider.dart';
import 'package:my_app/eCharts.dart';

import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final eChartsInstance = eCharts();
    // return MaterialApp(
    //   home: const HomePage(title: 'Chart App'),
    // );

    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => DataProvider(eChartsInstance),
        child: const HomePage(title: 'Chart App'),
      ),
    );
  }
}