import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/interfaces/i_ble.dart';
import 'package:sofia_app/models/BLECharacteristics.dart';
import 'package:sofia_app/models/BLESample.dart';

class BleService implements IBle {
  StreamController<BLESample> sampleController =
      StreamController<BLESample>.broadcast();

  final _sampleReceivedController = StreamController<BLESample>.broadcast();
  final _scanningEndController = StreamController<void>.broadcast();
  final _deviceConnectedController = StreamController<void>.broadcast();
  final _deviceDisconnectedController = StreamController<void>.broadcast();
  final _characteristicUpdatedController =
      StreamController<BLECharacteristics>.broadcast();

  List<BLESample> samples = [];
  bool isScanning = false;

  @override
  Stream<BLESample> get onSampleReceived => _sampleReceivedController.stream;

  @override
  Stream<void> get onScanningEnd => _scanningEndController.stream;

  @override
  Stream<void> get onDeviceConnected => _deviceConnectedController.stream;

  @override
  Stream<void> get onDeviceDisconnected => _deviceDisconnectedController.stream;

  @override
  Stream<BLECharacteristics> get onCharacteristicUpdated =>
      _characteristicUpdatedController.stream;

  @override
  Future<void> startScanningAsync(int scanTimeout) async {
    if (isScanning) {
      print("*******************if scan is already under process return");
      return; // Return or perform necessary actions if already scanning
    }

    try {
      isScanning = true; // Set scanning flag to true
      FlutterBluePlus.scan(
        timeout: Duration(seconds: 10),
        withServices: [
          // Guid(IBleService.FLOOR_SERVICE_GUID),
          Guid(IBle.carServiceGuid),
          Guid(IBle.floorServiceGuid)
        ],
      ).listen(
        (scanResult) {
          if (scanResult.device.localName.isNotEmpty) {
            var sample = BLESample(
              deviceId: scanResult.device.remoteId.str,
              alias: scanResult.device.localName,
              // deviceType: getDeviceType(
              //     scanResult.device, scanResult.advertisementData),
              timestamp: DateTime.now(),
              txPower: scanResult.advertisementData.txPowerLevel,
              rxPower: scanResult.rssi,
            );
            print(
                "***************************scanned sample before adding to stream************************$sample");
            samples.add(sample);
            _sampleReceivedController.add(sample);
          }
        },
        onDone: () {
          isScanning = false; // Set scanning flag to false when scan ends
          _scanningEndController.add(null);
        },
      );
    } catch (e) {
      isScanning = false; // Set scanning flag to false in case of errors
      print('Failed to start scanning: $e');
    }
  }

  // Future<void> connectToNearestDevice() async {
  //   if (!isScanning) {
  //     final nearestDevice = _findNearestConnectableDevice();
  //     if (nearestDevice != null &&
  //         await nearestDevice.connectionState !=
  //             BluetoothConnectionState.connected) {
  //       await connectToDevice(nearestDevice);
  //       await _handleDeviceConnected(nearestDevice);
  //     }
  //   }
  // }

  // BluetoothDevice _findNearestConnectableDevice() {
  //   final nearbyDevicesList = nearbyDevices.values;
  //   final nearestDevice = nearbyDevicesList.firstWhere(
  //     (device) =>
  //         device.connectable &&
  //         device.rssi == nearbyDevicesList.map((d) => d.rssi).reduce(math.max),
  //     orElse: () => null,
  //   );
  //   return nearestDevice;
  // }

  // Future<void> _handleDeviceConnected(BluetoothDevice device) async {
  //   log('Device connected ----------->>  ${device.remoteId.str}');
  //   await showNotification(
  //       'Connected to ${device.localName} ${device.remoteId.str}}');

  //   await readCharacteristic(device);
  //   await removedAllConnectedDevice();
  // }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: true);
  }

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
