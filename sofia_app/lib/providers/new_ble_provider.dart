import 'package:flutter/cupertino.dart';
import 'package:sofia_app/services/ble_helper.dart';

class NewBleProvider extends ChangeNotifier {

  BLEHelper bleHelper;

  NewBleProvider(this.bleHelper);

  void connectToNearestDevice() {
    bleHelper.startScanning();
  }

}