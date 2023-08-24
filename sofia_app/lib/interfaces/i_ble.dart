import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class IBle {
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
    Duration timeout = const Duration(seconds: 10),
    bool autoConnect = false,
  });
  Future<void> disconnect({int timeout = 10});

  Stream<List<ScanResult>> get scanResults;
  Stream<BluetoothAdapterState> get adapterState;
  Future<List<BluetoothDevice>> get connectedSystemDevices;
  Future<BluetoothConnectionState> get connectionState;
  Future<List<BluetoothService>> get servicesStream;

  Future<List<BluetoothService>> discoverServices();
}
