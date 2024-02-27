import 'dart:collection';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDevice {
  var limitQueue = LimitedQueue<ScanResult>(5);
  ScanResult scanResult;

  BLEDevice(this.scanResult) {
    limitQueue.add(scanResult);
  }

  void add(ScanResult scanResult) {
    limitQueue.add(scanResult);
  }

  double get average {
    if (limitQueue.size == 0) {
      return 0.0;
    }

    // Calculate sum
    double sum = 0.0;
    for (final ScanResult value in limitQueue.list) {
      sum += value.rssi;
    }

    return sum / limitQueue.size;
  }

  @override
  String toString() {
    return scanResult.toString();
  }
}

class LimitedQueue<T> {
  final int _limit;
  final List<T> _list = []; // Internal list to store elements

  LimitedQueue(this._limit);

  void add(T element) {
    if (_list.length >= _limit) {
      _list.removeAt(0); // Remove first element if full
    }
    _list.add(element);
  }

  int get size => _list.length;

  List<T> get list => _list;

  @override
  String toString() => _list.toString();
}
