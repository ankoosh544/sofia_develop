import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CharData {
  BluetoothCharacteristic bluetoothCharacteristic;

  CharData(this.bluetoothCharacteristic) {
    bluetoothCharacteristic.setNotifyValue(true);
    bluetoothCharacteristic.onValueReceived.listen((event) {

    });
  }
}