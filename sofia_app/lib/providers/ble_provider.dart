import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:rxdart/rxdart.dart';

import '../configs/index.dart';

class BleProvider extends ChangeNotifier {
  final _scanResult = BehaviorSubject<List<ScanResult>>.seeded([]);
  Stream<List<ScanResult>> get scanResult => _scanResult.stream;
  StreamSubscription? _subscription;

  final _connectedDevice = BehaviorSubject<List<BluetoothDevice>>.seeded([]);
  Stream<List<BluetoothDevice>> get connectedDeviceStream =>
      _connectedDevice.stream;
  BluetoothDevice? get connectedDevice =>
      _connectedDevice.value.isEmpty ? null : _connectedDevice.value.first;

  final _bluetoothState =
      BehaviorSubject<BluetoothState>.seeded(BluetoothState.unknown);
  Stream<BluetoothState> get bluetoothStateStream => _bluetoothState.stream;
  BluetoothState get bluetoothState => _bluetoothState.value;

  final _isScanning = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isScanningStream => _isScanning.stream;
  bool get isScanning => _isScanning.value;

  BleProvider() {
    _getBluetoothState();
    _getScanResults();
    _scanResult.listen((scanResults) {
      if (scanResults.isNotEmpty) {
        final nearestDevice = scanResults
            .reduce((curr, next) => curr.rssi > next.rssi ? curr : next);
        for (var scannedDevice in scanResults) {
          //if (nearestDevice.device.id != scannedDevice.device.id) {
          scannedDevice.device.disconnect();
          //}
        }

        nearestDevice.device.connect();
        log('Scanned Device connected ${nearestDevice.toString()}');
      }
    });
  }

  void initialScan() {
    if (!FlutterBluePlus.instance.isScanningNow) {
      startScan();
    }
  }

  void periodicScan() => _subscription =
      Stream.periodic(const Duration(seconds: periodicDuration), (_) => _)
          .listen((_) => startScan());

  void startScan() {
    if (bluetoothState == BluetoothState.on) {
      setIsScanning(true);
      FlutterBluePlus.instance.startScan(
        withServices: isServiceGuid ? serviceGuids : [],
        timeout: const Duration(seconds: timeoutDuration),
      );
    }
    _getConnectedDevice();
  }

  void stopScan() {
    FlutterBluePlus.instance.stopScan();
    clearSubscription();
    _refresh();
  }

  void _refresh() {
    setIsScanning(false);
    _scanResult.add([]);
    _connectedDevice.add([]);
  }

  void setIsScanning(bool value) => _isScanning.add(value);

  void _getScanResults() {
    FlutterBluePlus.instance.scanResults.listen((results) => _scanResult
        .add([results, _scanResult.value].expand((x) => x).toSet().toList()));
  }

  void _getConnectedDevice() async {
    final devices = await FlutterBluePlus.instance.connectedDevices;
    _connectedDevice.value.clear();
    _connectedDevice.add(devices);
  }

  void clearSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    clearSubscription();
    super.dispose();
  }

  void _getBluetoothState() => FlutterBluePlus.instance.state.listen((event) {
        if (event == BluetoothState.on) {
          startScan();
        } else {
          stopScan();
        }
        _bluetoothState.add(event);
      });
}
