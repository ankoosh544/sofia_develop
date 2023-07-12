import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../configs/index.dart';
import 'package:rxdart/rxdart.dart';

class HomeProvider extends ChangeNotifier {
  String _title = tabHome;
  String get title => _title;

  final _scanResult = BehaviorSubject<List<ScanResult>>.seeded([]);
  Stream<List<ScanResult>> get scanResult => _scanResult.stream;
  StreamSubscription? _subscription;

  void periodicScan() {
    _subscription =
        Stream.periodic(const Duration(seconds: 4), (_) => _).listen((event) {
      FlutterBluePlus.instance.startScan(
        withServices: serviceGuids,
        timeout: const Duration(seconds: 2),
      );
    });
  }

  void getScanResults() => FlutterBluePlus.instance.scanResults
      .listen((results) => _scanResult.add(results));

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void stopScan() {
    FlutterBluePlus.instance.stopScan();
    _subscription?.cancel();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
