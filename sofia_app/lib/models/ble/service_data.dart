import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServiceData {
  BluetoothService bluetoothService;
  List<BluetoothCharacteristic> bluetoothCharacteristics;

  ServiceData(this.bluetoothService, this.bluetoothCharacteristics);
}