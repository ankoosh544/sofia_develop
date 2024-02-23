import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic_callback.dart';

abstract class IBLEHelper {
  void scanNearestBleDevice(Function callback);
  void connectToBleDevice(ScanResult result, Function callback);
  void listenCharacteristics(BluetoothDevice bleDevice, BluetoothService bleService, CharacteristicCallback callback);
  void bluetoothOnOff(Function callback);
  void writeFloor(int floor);
}