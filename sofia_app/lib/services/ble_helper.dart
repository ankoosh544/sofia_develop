import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/interfaces/characteristic_callback.dart';
import 'package:sofia_app/models/ble/BLESample.dart';

import '../enums/direction.dart';
import '../enums/type_mission_status.dart';
import '../interfaces/i_ble_helper.dart';

class BLEHelper implements IBLEHelper {
  static const FLOOR_SERVICE_GUID = "6c962546-6011-4e1b-9d8c-05027adb3a01";
  static const CAR_SERVICE_GUID = "6c962546-6011-4e1b-9d8c-05027adb3a02";

  static const floorRequestCharacteristicGuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8"; //used to send new target plans and priorities

  static const floorChangeCharacteristicGuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a9"; // send to the phone where the booth is

  static const missionStatusCharacteristicGuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26aa"; // cabin on the destination floor7

  static const outOfServiceCharacteristicGuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26ab"; // out of service lift default 0

  // static const movementDirectionCar =
  //     "beb5483e-36e1-4688-b7f5-ea07361b26ac"; // movement and direction of the car
// byte 0 = 1 car moving
// byte 1 = 0 Car up
// byte 1 = 1 Car down

  // static const ESP_SERVICE_GUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  final List<Guid> serviceGuids = [
    Guid(FLOOR_SERVICE_GUID), // FLOOR_SERVICE_GUID
    // Guid(CAR_SERVICE_GUID), // CAR_SERVICE_GUID
    // Guid(ESP_SERVICE_GUID), // ESP32
  ];

  List<BLEDevice> devices = [];

  Timer? _timerForChar;
  int charIndex = 0;

  BluetoothService? floorService;

  BLEDevice? newNearestDevice;

  @override
  void scanDevices(final Function(BLEDevice) callback) async {
    // Start scanning
    var subscription = FlutterBluePlus.scanResults
        .listen((final List<ScanResult> results) async {
      debugPrint("Scanning BLE Devices");
      if (results.isEmpty) return;

      print("Devices: ${results.length}:  ${results[0].device.platformName.codeUnits.toString()}");

      var newNearestDevice = BLEDevice(results[0], LimitedQueue<ScanResult>(4));
      callback(newNearestDevice);
    });
    // cleanup: cancel subscription when scanning stops
    // FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.startScan(
        withServices: serviceGuids,
        continuousUpdates: true,
        oneByOne: true,
        nearestDevice: true,
        androidUsesFineLocation: false);
    // wait for scanning to stop
    var isScanning =
        await FlutterBluePlus.isScanning.where((val) => val == false).first;
    debugPrint("Is Scanning: $isScanning");
  }

  bool isFloor(ScanResult scanResult) =>
      scanResult.advertisementData.serviceUuids.contains(serviceGuids[0]);

// Discover services and characteristics after connecting
  @override
  void listenCharacteristics(
      final BluetoothDevice bleDevice,
      final BluetoothService bleService,
      final CharacteristicCallback callback) async {
    floorService = bleService;
    _timerForChar?.cancel();
    _timerForChar =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (bleDevice.isDisconnected) {
        devices.remove(bleDevice);
        nearestDevice = null;
        debugPrint("Disconnected Device");
        _timerForChar?.cancel();
        return;
      }

      if(charIndex == 0) {

        void floorChange(List<int> event) {
          if (event.isEmpty) return;
          // debugPrint("floorChange: $event");

          // if(areEqual(event, floorChangeData)) {
          //   debugPrint("Same Data");
          //   return;
          // }

          // floorChangeData = event;

          String carFloor = ((event[0] & 0x3F)).toString();
          // debugPrint("Car Floor: $carFloor");

          var light = false;
          var movement = Direction.stopped;

          if ((event[0] & 0x40) == 0x40) {
            // debugPrint("PresenceOfLight: true");
            light = true;
          } else {
            // debugPrint("PresenceOfLight: false");
            light = false;
          }

          if ((event[1] & 0x1) == 0x1) {
            if ((event[1] & 0x02) == 0x02) {
              // debugPrint("CarDirection = Direction.Up");
              movement = Direction.up;
            } else {
              // debugPrint("CarDirection = Direction.Down");
              movement = Direction.down;
            }
          } else {
            // debugPrint("CarDirection = Direction.Stopped");
            movement = Direction.stopped;
          }

          callback.floorChange(int.parse(carFloor), light, movement);
        }

        // debugPrint(floorChangeCharacteristicGuid);
      var floorChangeCharacteristic = bleService.characteristics
          .firstWhereOrNull((element) =>
              element.characteristicUuid.str == floorChangeCharacteristicGuid);

        try {
          if (floorChangeCharacteristic?.properties.read == true) {
            if (bleDevice.isConnected) {
              floorChange(await floorChangeCharacteristic?.read() ?? []);
            } else {
              debugPrint("Device Disconnect While Read Char");
            }
          }
        } catch (e) {
          debugPrint("Read Char Error: $e");
        }
      }

      if (charIndex == 1) {

        // mission Status Characteristic data
        void missionStatus(List<int> event) {
          if (event.isEmpty) return;
          // debugPrint("Mission Stat: $event");

          // if(areEqual(event, missionStateData)) {
          //   debugPrint("Same Data");
          //   return;
          // }

          // missionStateData = event;

          if (event.length > 2) {
            var missionStatus = event[0];
            var eta = event[1] * 256 + event[2];

            // debugPrint("Mission Stat: $missionStatus, ETA: $eta");
            callback.missionStatus(TypeMissionStatus.values[missionStatus], eta);
          }
        }

        // debugPrint(missionStatusCharacteristicGuid);
        var missionStatusCharacteristic = bleService.characteristics
            .firstWhereOrNull((element) =>
                element.characteristicUuid.str ==
                missionStatusCharacteristicGuid);

        try {
          if (missionStatusCharacteristic?.properties.read == true) {
            if (bleDevice.isConnected) {
              missionStatus(await missionStatusCharacteristic?.read() ?? []);
            } else {
              debugPrint("Device Disconnect While Read Char");
            }
          }
        } catch (e) {
          debugPrint("Read Char Error: $e");
        }
      }

      if (charIndex == 2) {

        // out Of Service Characteristic data
        void outOfService(List<int> event) {
          if (event.isEmpty) return;
          // debugPrint("OutOfService: $event");

          // if(areEqual(event, outOfServiceData)) {
          //   debugPrint("Same Data");
          //   return;
          // }

          // outOfServiceData = event;

          if (event[0] == 0) {
            callback.serviceStatus(false);
            // debugPrint("this.OutOfService = false;");
          } else {
            callback.serviceStatus(true);
            // debugPrint("this.OutOfService = true;");
          }
        }

        // debugPrint(outOfServiceCharacteristicGuid);
        var outOfServiceCharacteristic = bleService.characteristics
            .firstWhereOrNull((element) =>
                element.characteristicUuid.str ==
                outOfServiceCharacteristicGuid);

        try {
          // outOfServiceCharacteristic?.setNotifyValue(true);
          if (outOfServiceCharacteristic?.properties.read == true) {
            if (bleDevice.isConnected) {
              outOfService(await outOfServiceCharacteristic?.read() ?? []);
            } else {
              debugPrint("Device Disconnect While Read Char");
            }
          }
        } catch (e) {
          debugPrint("Read Char Error: $e");
        }
      }
      if (charIndex < 3) {
        charIndex++;
      } else {
        charIndex = 0;
      }
    });

    ///////////////////////////Change Floor//////////////////////////////

    void floorChange(List<int> event) {
      if (event.isEmpty) return;
      // debugPrint("floorChange: $event");

      // if(areEqual(event, floorChangeData)) {
      //   debugPrint("Same Data");
      //   return;
      // }

      // floorChangeData = event;

      String carFloor = ((event[0] & 0x3F)).toString();
      // debugPrint("Car Floor: $carFloor");

      var light = false;
      var movement = Direction.stopped;

      if ((event[0] & 0x40) == 0x40) {
        // debugPrint("PresenceOfLight: true");
        light = true;
      } else {
        // debugPrint("PresenceOfLight: false");
        light = false;
      }

      if ((event[1] & 0x1) == 0x1) {
        if ((event[1] & 0x02) == 0x02) {
          // debugPrint("CarDirection = Direction.Up");
          movement = Direction.up;
        } else {
          // debugPrint("CarDirection = Direction.Down");
          movement = Direction.down;
        }
      } else {
        // debugPrint("CarDirection = Direction.Stopped");
        movement = Direction.stopped;
      }

      callback.floorChange(int.parse(carFloor), light, movement);
    }

    var floorChangeCharacteristic = bleService.characteristics.firstWhereOrNull(
        (element) =>
            element.characteristicUuid.str == floorChangeCharacteristicGuid);

    try {

      floorChangeCharacteristic?.setNotifyValue(true);
      StreamSubscription<List<int>>? sub =
          floorChangeCharacteristic?.onValueReceived.listen((event) {
            if(bleDevice.isConnected) {
              floorChange(event);
              debugPrint("Device connected: ${bleDevice.platformName.codeUnits.toString()}");
            } else {
              debugPrint("Device not connected: ${bleDevice.platformName.codeUnits.toString()}");
            }
      });
      if (sub != null) bleDevice.cancelWhenDisconnected(sub);
    } catch (e) {
      debugPrint("Read Char Error: $e");
    }

    ///////////////////////////Out Of Service//////////////////////////////

        // out Of Service Characteristic data
        void outOfService(List<int> event) {
          if (event.isEmpty) return;
          // debugPrint("OutOfService: $event");

          // if(areEqual(event, outOfServiceData)) {
          //   debugPrint("Same Data");
          //   return;
          // }

          // outOfServiceData = event;

          if (event[0] == 0) {
            callback.serviceStatus(false);
            // debugPrint("this.OutOfService = false;");
          } else {
            callback.serviceStatus(true);
            // debugPrint("this.OutOfService = true;");
          }
        }

    // debugPrint(outOfServiceCharacteristicGuid);
        var outOfServiceCharacteristic = bleService.characteristics
            .firstWhereOrNull((element) =>
                element.characteristicUuid.str ==
                outOfServiceCharacteristicGuid);

        try {
          outOfServiceCharacteristic?.setNotifyValue(true);
          StreamSubscription<List<int>>? sub =
          outOfServiceCharacteristic?.onValueReceived.listen((event) {
            if(bleDevice.isConnected) {
              outOfService(event);
              debugPrint("Device connected: ${bleDevice.platformName.codeUnits.toString()}");
            } else {
              debugPrint("Device not connected: ${bleDevice.platformName.codeUnits.toString()}");
            }
          });
          if (sub != null) bleDevice.cancelWhenDisconnected(sub);
        } catch (e) {
          debugPrint("Read Char Error: $e");
        }


    ///////////////////////////Mission Status//////////////////////////////
        // mission Status Characteristic data
        void missionStatus(List<int> event) {
          if (event.isEmpty) return;
          // debugPrint("Mission Stat: $event");

          // if(areEqual(event, missionStateData)) {
          //   debugPrint("Same Data");
          //   return;
          // }

          // missionStateData = event;

          if (event.length > 2) {
            var missionStatus = event[0];
            var eta = event[1] * 256 + event[2];

            // debugPrint("Mission Stat: $missionStatus, ETA: $eta");
            callback.missionStatus(TypeMissionStatus.values[missionStatus], eta);
          }
        }

        // debugPrint(missionStatusCharacteristicGuid);
        var missionStatusCharacteristic = bleService.characteristics
            .firstWhereOrNull((element) =>
                element.characteristicUuid.str ==
                missionStatusCharacteristicGuid);

    try {
      missionStatusCharacteristic?.setNotifyValue(true);
      StreamSubscription<List<int>>? sub =
      missionStatusCharacteristic?.onValueReceived.listen((event) {
        if(bleDevice.isConnected) {
          outOfService(event);
          debugPrint("Device connected: ${bleDevice.platformName.codeUnits.toString()}");
        } else {
          debugPrint("Device not connected: ${bleDevice.platformName.codeUnits.toString()}");
        }
      });
      if (sub != null) bleDevice.cancelWhenDisconnected(sub);
    } catch (e) {
      debugPrint("Read Char Error: $e");
    }

  }

  @override
  void writeFloor(int floor) {
    BluetoothCharacteristic? floorRequestCharacteristic =
        floorService?.characteristics.firstWhereOrNull(
            (element) => element.uuid.str == floorRequestCharacteristicGuid);

    debugPrint("writeFloor: $floorRequestCharacteristic");

    floorRequestCharacteristic?.write([floor, 0]);
  }

  @override
  void connectToBleDevice(final BLEDevice result,
      final Function(BluetoothConnectionState) callback) async {
    if (result.scanResult.device.isDisconnected) {
      var subscription = result.scanResult.device.connectionState
          .listen((BluetoothConnectionState state) {
        debugPrint(state == BluetoothConnectionState.connected
            ? "BLE Device Connect"
            : "BLE Device Disconnect");
        if (result.scanResult.device.isDisconnected) {
          devices.remove(result);
          nearestDevice = null;
          debugPrint("Removed: $result");
        }
        callback(state);
      });
      result.scanResult.device
          .cancelWhenDisconnected(subscription, delayed: true, next: true);
      await result.scanResult.device
          .connect(autoConnect: false);
    } else {
      callback(BluetoothConnectionState.connected);
    }
  }

  @override
  void bluetoothOnOff(final Function callback) {
    // handle bluetooth on & off
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      debugPrint(" Bluetooth State: $state");
      callback(state);
    });
  }

  @override
  BLEDevice? nearestDevice;
}
