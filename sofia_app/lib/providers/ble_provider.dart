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
  //BluetoothDevice? connectedDevice;

  final _bluetoothState = BehaviorSubject<BluetoothAdapterState>.seeded(
      BluetoothAdapterState.unknown);
  Stream<BluetoothAdapterState> get bluetoothStateStream =>
      _bluetoothState.stream;
  BluetoothAdapterState get bluetoothState => _bluetoothState.value;

  final _isScanning = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isScanningStream => _isScanning.stream;
  bool get isScanning => _isScanning.value;
  late BluetoothDevice connectedDevice;

  BleProvider() {
    _getBluetoothState();
    _getScanResults();

    // Modify the original code
    scanResult.listen((scanResults) async {
      if (scanResults.isNotEmpty) {
        final nearestDevice = scanResults.reduce(
            (current, next) => current.rssi > next.rssi ? current : next);
        //if (nearestDevice.device.remoteId.str !=
        //    connectedDevice?.remoteId.str) {
        //  await connectedDevice?.disconnect();
        // }
        connectedDevice = nearestDevice.device;

        // connectedDevices.add(nearestDevice.device);

        final connectionState =
            await nearestDevice.device.connectionState.first;
        switch (connectionState) {
          case BluetoothConnectionState.disconnected:
          case BluetoothConnectionState.connecting:
          case BluetoothConnectionState.disconnecting:
            await nearestDevice.device.connect();
            _getConnectedDevice(nearestDevice.device);
            log('Scanned Device connected ->> ${nearestDevice.toString()}');
            final connectedDevices =
                await FlutterBluePlus.connectedSystemDevices;
            for (var element in connectedDevices) {
              if (nearestDevice.device.remoteId.str != element.remoteId.str) {
                await element.disconnect();
              }
            }
            break;
          case BluetoothConnectionState.connected:
            log('Device already connected.............. ${nearestDevice.device.remoteId.str}');
            break;
        }
        //test();
      }
    });
  }

  // Function to disconnect from a device
  Future<void> _disconnectDevice(BluetoothDevice device) async {
    if (device != null &&
        device.connectionState == BluetoothConnectionState.connected) {
      await device.disconnect();
    }
  }

// Function to remove all connected devices from the list
  Future<void> _removeAllConnectedDevices() async {
    final connectedDevices = await FlutterBluePlus.connectedSystemDevices;
    for (var device in connectedDevices) {
      await _disconnectDevice(device);
    }
  }

  void _getScanResults() {
    //FlutterBluePlus.scanResults.listen((results) => _scanResult
    //   .add([results, _scanResult.value].expand((x) => x).toSet().toList()));
    FlutterBluePlus.scanResults.listen((event) {
      _scanResult.add(event);
    });
  }

  Future test() async {
    await connectedDevice.discoverServices();
    connectedDevice.servicesStream.listen((services) {
      if (services.isNotEmpty) {
        services.forEach((service) {
          if (service.characteristics.isNotEmpty) {
            service.characteristics.forEach((characteristic) {
              characteristic.read();
              print(
                  '0x${characteristic.characteristicUuid.toString().toUpperCase().substring(4, 8)}');
              print(
                  'Device Name: ${String.fromCharCodes(characteristic.lastValue)}');
            });
          }
        });
      }
    });
  }

  // void periodicScan() => _subscription =
  //     Stream.periodic(const Duration(milliseconds: periodicDuration), (_) => _)
  //         .listen((_) => initialScan());

  void startScanning() {
    if (FlutterBluePlus.isScanningNow == false) {
      FlutterBluePlus.startScan(
        withServices: isServiceGuid ? serviceGuids : [],
        timeout: const Duration(days: timeoutDuration),
        androidUsesFineLocation: false,
      );
    }
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

  void _getConnectedDevice(BluetoothDevice device) {
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
          startScanning();
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
