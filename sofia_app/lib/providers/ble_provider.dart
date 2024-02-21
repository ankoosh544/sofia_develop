import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/services/ble_helper.dart';

import '../configs/constants.dart';
import '../enums/direction.dart';
import '../enums/type_mission_status.dart';
import '../interfaces/characteristic_callback.dart';

class BleProvider extends ChangeNotifier implements CharacteristicCallback {
  BLEHelper bleHelper;

  var carFloor = 0;

  var carDirection = Direction.stopped;

  var outOfService = false;

  int? bleDeviceName;

  bool lightStatus = false;

  var typeMissionStatus = TypeMissionStatus.missionNoInit;

  int eta = -1;

  var deviceConnected = false;

  BleProvider(this.bleHelper);

  void connectToNearestDevice() {
    bleHelper.scanNearestBleDevice((BluetoothDevice bleDevice) {
      bleHelper.connectToBleDevice(bleDevice, (state) async {
        if (state == BluetoothConnectionState.connected) {
          deviceConnected = true;
          bleDeviceName = getFloorNumber(bleDevice.platformName);
          print("localName${bleDeviceName}");
          List<BluetoothService> services = await bleDevice.discoverServices();
          BluetoothService? myService = services.firstWhereOrNull((service) =>
              service.uuid.str.toUpperCase() == FLOOR_SERVICE_GUID);
          if (myService != null) {
            bleHelper.listenCharacteristics(myService, this);
          }
        } else {
          deviceConnected = false;
        }
        notifyListeners();
      });
    });
  }

  int getFloorNumber(String inputString) {
    final RegExp regex = RegExp(r'\d+');
    final Match? match = regex.firstMatch(inputString);
    if (match != null) {
      final String numberAsString = match.group(0)!;
      return int.parse(numberAsString);
    }

    return 0;
  }

  void bluetoothOnOff() {
    bleHelper.bluetoothOnOff((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
        // turn on bluetooth ourself if we can
// for iOS, the user controls bluetooth enable/disable
//         if (Platform.isAndroid) {
//           FlutterBluePlus.turnOn();
//         }
      }
    });
  }

  @override
  void floorChange(int floor) {
    carFloor = floor;
    notifyListeners();
  }

  @override
  void missionStatus(TypeMissionStatus status, int eta) {
    typeMissionStatus = status;
    this.eta = eta;
    notifyListeners();
  }

  @override
  void movement(Direction direction) {
    carDirection = direction;
    notifyListeners();
  }

  @override
  void serviceStatus(bool outOfService) {
    this.outOfService = outOfService;
    notifyListeners();
  }

  @override
  void light(bool present) {
    lightStatus = present;
    notifyListeners();
  }
}
