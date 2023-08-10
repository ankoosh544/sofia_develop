import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:rxdart/rxdart.dart';

import '../configs/index.dart';

abstract class Ble {
  Future<void> startScan({
    ScanMode scanMode = ScanMode.lowLatency,
    List<Guid> withServices = const [],
    List<String> macAddresses = const [],
    Duration? timeout,
    bool allowDuplicates = false,
    bool androidUsesFineLocation = false,
  });
  Future<void> stopScan();

  bool get isScanningNow;
  Future<ScanResult> get nearestScan;
  Future<BluetoothDevice> get nearestDevice;
  Future<void> connect({
    Duration timeout = const Duration(seconds: 15),
    bool autoConnect = false,
  });
  Future<void> disconnect({int timeout = 15});

  Stream<List<ScanResult>> get scanResults;
  Stream<BluetoothAdapterState> get adapterState;
  Future<List<BluetoothDevice>> get connectedSystemDevices;
  Future<BluetoothConnectionState> get connectionState;
  Future<List<BluetoothService>> get servicesStream;

  Future<List<BluetoothService>> discoverServices();
}

class BleImpl extends Ble {
  @override
  Future<void> startScan({
    ScanMode scanMode = ScanMode.lowLatency,
    List<Guid> withServices = const [],
    List<String> macAddresses = const [],
    Duration? timeout,
    bool allowDuplicates = false,
    bool androidUsesFineLocation = false,
  }) async =>
      FlutterBluePlus.startScan(
        scanMode: scanMode,
        withServices: withServices,
        timeout: timeout,
        macAddresses: macAddresses,
        allowDuplicates: allowDuplicates,
        androidUsesFineLocation: androidUsesFineLocation,
      );

  @override
  Future<void> stopScan() async => FlutterBluePlus.stopScan();

  @override
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  @override
  Future<List<BluetoothDevice>> get connectedSystemDevices =>
      FlutterBluePlus.connectedSystemDevices;

  @override
  Future<BluetoothConnectionState> get connectionState async =>
      (await nearestDevice).connectionState.first;

  @override
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  @override
  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  @override
  Future<BluetoothDevice> get nearestDevice async {
    return (await nearestScan).device;
  }

  @override
  Future<ScanResult> get nearestScan async => (await scanResults.first)
      .reduce((current, next) => current.rssi > next.rssi ? current : next);

  @override
  Future<void> connect({
    Duration timeout = const Duration(seconds: 15),
    bool autoConnect = false,
  }) async =>
      (await nearestDevice).connect(timeout: timeout, autoConnect: autoConnect);

  @override
  Future<void> disconnect({int timeout = 15}) async =>
      (await nearestDevice).disconnect(timeout: timeout);

  @override
  Future<List<BluetoothService>> get servicesStream async =>
      (await nearestDevice).servicesStream.first;

  @override
  Future<List<BluetoothService>> discoverServices() async =>
      (await nearestDevice).discoverServices();
}

class BleProvider extends ChangeNotifier {
  final Ble ble;
  final _connectedDevice = BehaviorSubject<List<BluetoothDevice>>.seeded([]);
  Stream<List<BluetoothDevice>> get connectedDeviceStream =>
      _connectedDevice.stream;

  final _bluetoothState = BehaviorSubject<BluetoothAdapterState>.seeded(
      BluetoothAdapterState.unknown);
  Stream<BluetoothAdapterState> get bluetoothStateStream =>
      _bluetoothState.stream;
  BluetoothAdapterState get bluetoothState => _bluetoothState.value;

  BleProvider(this.ble) {
    _getBluetoothState();
    ble.scanResults.listen((event) async {
      final device = await ble.nearestDevice;
      if (await ble.connectionState != BluetoothConnectionState.connected &&
          (await ble.nearestScan).advertisementData.connectable) {
        await ble.connect();
        await ble.discoverServices();
        await removedAllConnectedDevice();
        log('Device connected ----------->>  ${device.remoteId.str}');
        await readCharacteristic();
      } else {
        log('Else Device connected ----------->>  ${device.remoteId.str}');
      }
    });
  }

  void _getBluetoothState() => ble.adapterState.listen((event) {
        if (event == BluetoothAdapterState.on) {
          startScanning();
        } else {
          stopScan();
        }
        _bluetoothState.add(event);
      });

  void startScanning() async {
    if (ble.isScanningNow == false) {
      await ble.startScan(
        withServices: isServiceGuid ? serviceGuids : [],
        timeout: const Duration(days: timeoutDuration),
        androidUsesFineLocation: false,
      );
    }
  }

  void stopScan() async {
    await ble.stopScan();
    _refresh();
  }

  void _refresh() {
    _connectedDevice.value.clear();
  }

  Future<void> readCharacteristic() async {
    try {
      final connectionState = await ble.connectionState;
      if (connectionState == BluetoothConnectionState.connected) {
        final services = await ble.servicesStream;
        if (services.isNotEmpty) {
          for (var service in services) {
            if (service.characteristics.isNotEmpty) {
              for (var characteristic in service.characteristics) {
                if (characteristic.properties.read) {
                  if (characteristic.characteristicUuid
                          .toString()
                          .toUpperCase()
                          .substring(4, 8) ==
                      '2A00') {
                    final data = await characteristic.read();
                    print('PSK last value: ${String.fromCharCodes(data)}');

                    final device = await ble.nearestDevice;

                    final myDevice = BluetoothDevice.fromId(
                      device.remoteId.str,
                      localName: String.fromCharCodes(characteristic.lastValue),
                      type: device.type,
                    );
                    print(myDevice.toString());
                    setConnectedDevice(myDevice);
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future removedAllConnectedDevice() async {
    final connectedDevices = await ble.connectedSystemDevices;
    for (var device in connectedDevices) {
      if ((await ble.nearestDevice).remoteId.str != device.remoteId.str) {
        await device.disconnect();
      }
    }
  }

  void setConnectedDevice(BluetoothDevice device) {
    _connectedDevice.value.clear();
    _connectedDevice.add([device]);
  }

  void clearConnectedDevice() {
    _connectedDevice.value.clear();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  int getFloorNumber(String inputString) {
    final RegExp regex = RegExp(r'\d+');
    final Match? match = regex.firstMatch(inputString);
    if (match != null) {
      final String numberAsString = match.group(0)!;
      return int.parse(numberAsString);
    }

    // Return a default value (e.g., 0) if no numeric portion is found in the string.
    return 0;
  }
}
