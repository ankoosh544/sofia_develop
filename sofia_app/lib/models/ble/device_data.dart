import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/models/ble/service_data.dart';

class DeviceData {
  BluetoothDevice bluetoothDevice;
  List<ServiceData> bluetoothServices;

  DeviceData(this.bluetoothDevice, this.bluetoothServices);
}
