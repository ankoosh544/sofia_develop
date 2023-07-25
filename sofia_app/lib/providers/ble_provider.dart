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

  final _bluetoothState = BehaviorSubject<BluetoothAdapterState>.seeded(
      BluetoothAdapterState.unknown);
  Stream<BluetoothAdapterState> get bluetoothStateStream =>
      _bluetoothState.stream;
  BluetoothAdapterState get bluetoothState => _bluetoothState.value;

  final _isScanning = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isScanningStream => _isScanning.stream;
  bool get isScanning => _isScanning.value;

  BleProvider() {
    _getBluetoothState();
    _getScanResults();

    _scanResult.listen((scanResults) async {
      if (scanResults.isNotEmpty) {
        final nearestDevice = scanResults
            .reduce((curr, next) => curr.rssi > next.rssi ? curr : next);

        final connectedDevices = await FlutterBluePlus.connectedDevices;
        final event = await nearestDevice.device.connectionState.first;
        if (event != BluetoothConnectionState.connected) {
          nearestDevice.device.connect();
          _getConnectedDevice(nearestDevice.device);
          log('Scanned Device connected $connectedDevices ->> ${nearestDevice.toString()}');
        } else {
          log('Device already connected..............');
        }
      }
    });
    //test();
  }

  Future test() async {
    connectedDevice?.services.listen((event) {
      if (event.isNotEmpty) {
        event.forEach((element) {
          if (element.characteristics.isNotEmpty) {
            element.characteristics.forEach((data) {
              data.read();
              print(
                  '0x${data.characteristicUuid.toString().toUpperCase().substring(4, 8)}');
              print('Device Name: ${String.fromCharCodes(data.lastValue)}');
            });
          }
        });
      }
    });
  }

  void initialScan() {
    if (!FlutterBluePlus.isScanningNow) {
      startScan();
    }
  }

  void periodicScan() => _subscription =
      Stream.periodic(const Duration(milliseconds: periodicDuration), (_) => _)
          .listen((_) => initialScan());

  void startScan() {
    if (bluetoothState == BluetoothAdapterState.on) {
      setIsScanning(true);
      FlutterBluePlus.startScan(
        withServices: isServiceGuid ? serviceGuids : [],
        timeout: const Duration(milliseconds: timeoutDuration),
      );
    }
    _getConnectedDevice();
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
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
    FlutterBluePlus.scanResults.listen((results) => _scanResult
        .add([results, _scanResult.value].expand((x) => x).toSet().toList()));
  }

  void _getConnectedDevice([BluetoothDevice? device]) async {
    if (device == null) return;
    _connectedDevice.value.clear();
    _connectedDevice.add([device]);
  }

  void clearSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  // num getDistance(int rssi, int txPower) {
  //   /*
  //    * RSSI = TxPower - 10 * n * lg(d)
  //    * n = 2 (in free space)
  //    *
  //    * d = 10 ^ ((TxPower - RSSI) / (10 * n))
  //    */
  //
  //
  //   return math.pow(10d, ((double) txPower - rssi) / (10 * 2));
  // }

  @override
  void dispose() {
    clearSubscription();
    super.dispose();
  }

  void _getBluetoothState() => FlutterBluePlus.adapterState.listen((event) {
        if (event == BluetoothAdapterState.on) {
          initialScan();
        } else {
          stopScan();
        }
        _bluetoothState.add(event);
      });

  Stream<int> rssiStream(BluetoothDevice device) async* {
    var isConnected = true;
    final subscription = device.connectionState.listen((state) {
      isConnected = state == BluetoothConnectionState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
