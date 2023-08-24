import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/interfaces/i_ble.dart';

class BleService extends IBle {
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
