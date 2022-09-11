// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:my_app/eCharts.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, required this.title}) : super(key: key);
  @override
  State<HomePage> createState() => eCharts();
}