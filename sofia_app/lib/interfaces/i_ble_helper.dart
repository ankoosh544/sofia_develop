import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic_callback.dart';

abstract class IBLEHelper {
  void scanNearestBleDevice(Function callback);
  void connectToBleDevice(BluetoothDevice bleDevice, Function callback);
  void listenCharacteristics(BluetoothService bleService, CharacteristicCallback callback);
  void bluetoothOnOff(Function callback);
  void writeFloor(int floor);
}