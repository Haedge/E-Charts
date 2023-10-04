import 'package:flutter/material.dart';
// import 'package:tuple/tuple.dart';

import 'Baseball_Pieces/Player.dart';
// import 'package:provider/provider.dart';

import 'eCharts.dart';

class DataProvider with ChangeNotifier {
  List<Player> _pitchers = [];

  List<Player> get pitchers => _pitchers;

  final eCharts eChartsInstance;

  DataProvider(this.eChartsInstance);

  Future<void> fetchData() async {
    if (_pitchers.isEmpty) {
      try {
        final tuple = await eChartsInstance.fetchPitchers();
        _pitchers = pitchers;
        notifyListeners(); // Notify listeners that the data has changed.
      } catch (error) {
        print('Error fetching pitchers: $error');
      }
    }
  }
}