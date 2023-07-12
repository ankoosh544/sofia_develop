import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../configs/index.dart';

class HomeProvider extends ChangeNotifier {
  String _title = tabHome;
  String get title => _title;

  final List<ScanResult> _scanResult = [];
  List<ScanResult> get scanResult => _scanResult;

  HomeProvider() {
    FlutterBluePlus.instance.startScan(
      withServices: serviceGuids,
      timeout: const Duration(seconds: 10),
    );

    FlutterBluePlus.instance.scanResults
        .listen((results) => _scanResult.addAll);
  }

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }
}
