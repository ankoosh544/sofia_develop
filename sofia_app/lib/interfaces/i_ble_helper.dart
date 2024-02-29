import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/models/ble/BLESample.dart';

import 'characteristic_callback.dart';

abstract class IBLEHelper {
  BLEDevice? nearestDevice;
  void scanDevices(Function(BLEDevice) callback);
  void connectToBleDevice(BLEDevice result, Function(BluetoothConnectionState) callback);
  void listenCharacteristics(BluetoothDevice bleDevice, BluetoothService bleService, CharacteristicCallback callback);
  void bluetoothOnOff(Function callback);
  void writeFloor(int floor);
}