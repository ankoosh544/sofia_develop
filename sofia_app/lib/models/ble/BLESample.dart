import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDevice extends Equatable {
  final LimitedQueue<ScanResult> _limitQueue;
  final ScanResult scanResult;

  BLEDevice(this.scanResult, this._limitQueue) {
    _limitQueue.add(scanResult);
  }

  BLEDevice copyWith(ScanResult device) {
    _add(device);
    return BLEDevice(scanResult, _limitQueue);
  }

  BLEDevice _add(ScanResult scanResult) {
    _limitQueue.add(scanResult);
    return this;
  }

  double get average {
    if (_limitQueue.size == 0) {
      return 0.0;
    }

    // Calculate sum
    double sum = 0.0;
    for (final ScanResult value in _limitQueue.list) {
      sum += value.rssi;
    }

    return sum / _limitQueue.size;
  }

  @override
  String toString() {
    return scanResult.toString();
  }

  @override
  List<Object?> get props => [scanResult];
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
