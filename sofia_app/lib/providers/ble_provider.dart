import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/models/BLECharacteristics.dart';
import 'package:sofia_app/services/ble_helper.dart';

import '../enums/direction.dart';
import '../enums/type_mission_status.dart';
import '../interfaces/characteristic_callback.dart';
import '../interfaces/i_ble_helper.dart';

class BleProvider extends ChangeNotifier implements CharacteristicCallback {
  IBLEHelper bleHelper;

  var carFloor = 0;

  var carDirection = Direction.stopped;

  var outOfService = false;

  String? bleDeviceName;

  bool lightStatus = false;

  var typeMissionStatus = TypeMissionStatus.missionNoInit;

  int eta = -1;

  var deviceConnected = false;

  BluetoothService? floorService;

  BleProvider(this.bleHelper);

  void connectToNearestDevice() {
    bleHelper.scanNearestBleDevice((final ScanResult result) {
      if(result.device.isConnected) {
        connected(result);
      } else {
        floorService = null;
        bleHelper.connectToBleDevice(result, (final BluetoothConnectionState state) async {
          if (state == BluetoothConnectionState.connected) {
            connected(result);
          } else {
            floorService = null;
            deviceConnected = false;
            notifyListeners();
          }
        });
      }
    });
  }

  void connected(final ScanResult result) async {
    try {
      deviceConnected = true;
      bleDeviceName = result.device.platformName.codeUnits.toString();
      debugPrint("localName: $bleDeviceName");
      if(floorService == null) {
        List<BluetoothService> services =
        await result.device.discoverServices();
        floorService = services.firstWhereOrNull((service) =>
        service.uuid.str == BLEHelper.FLOOR_SERVICE_GUID);
      }

      if (floorService != null) {
        bleHelper.listenCharacteristics(result.device, floorService!, this);
        //writeFloor(2);
      }
    } catch (e) {
      debugPrint("Exception $e");
    }
    notifyListeners();
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

  void writeFloor(int floor) {
    bleHelper.writeFloor(floor);
  }

  void bluetoothOnOff() {
    bleHelper.bluetoothOnOff((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        debugPrint("BLE on");
      } else {
        debugPrint("BLE off");
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
  void floorChange(int floor, bool present, Direction direction) {
    carFloor = floor;
    carDirection = direction;
    lightStatus = present;
    notifyListeners();
  }

  @override
  void missionStatus(TypeMissionStatus status, int eta) {
    typeMissionStatus = status;
    this.eta = eta;
    notifyListeners();
  }

  @override
  void serviceStatus(bool outOfService) {
    this.outOfService = outOfService;
    notifyListeners();
  }
}
