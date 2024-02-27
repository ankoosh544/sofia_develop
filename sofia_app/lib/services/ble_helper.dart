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
    Guid(CAR_SERVICE_GUID), // CAR_SERVICE_GUID
    // Guid(ESP_SERVICE_GUID), // ESP32
  ];

  BLEDevice? oldNearestDevice;

  List<BLEDevice> devices = [];

  Timer? _timer;
  Timer? _timerForChar;

  BluetoothService? floorService;

  List<int>? floorChangeData;
  List<int>? missionStateData;
  List<int>? outOfServiceData;
  List<int>? movementData;

  void addItem(ScanResult device) {
    int index = devices
        .indexWhere((item) => item.scanResult == device); // Check for existing object
    if (index != -1) {
      devices[index].scanResult = device; // Replace existing object
      devices[index].add(device); // Replace existing object
    } else {
      devices.add(BLEDevice(device)); // Add new object
    }
  }

  @override
  void scanNearestBleDevice(final Function callback) async {
    // Start scanning

    _scanDevices();
    // Cancel any existing timer before starting a new one
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      // Your periodic task to be executed here
      debugPrint("Executing task");
      // await _stopScanDevices();
      _scanDevices();
    });

    FlutterBluePlus.scanResults.listen((final List<ScanResult> results) async {
      debugPrint("Scanning BLE Devices");
      if (results.isEmpty) return;

      for (var result in results) {
        addItem(result);
      }
      print("Devices: ${results.length}");
      print("Devices: ${devices.length}");

      // debugPrint("Results: ${results.toString()}");

      var newNearestDevice = findNearestScanResult(devices);
      var rssi = (-newNearestDevice.scanResult.rssi);
      print("near rssi: $rssi");

      print(
          "Device: ${newNearestDevice..scanResult.device.platformName.codeUnits.toString()}");

      if (isFloor(newNearestDevice.scanResult)) {
        //await oldNearestDevice?.device.disconnect();
        oldNearestDevice = newNearestDevice;
        callback(newNearestDevice.scanResult);
      }
    });
  }

  BLEDevice findNearestScanResult(final List<BLEDevice> scanResults) {
    BLEDevice nearestResult = scanResults.first;
    for (BLEDevice result in scanResults) {
      var rssi = -(result.average);
      print("RSSI: $rssi");
      if (rssi < -(nearestResult.average)) {
        // Smaller RSSI indicates closer proximity
        nearestResult = result;
      }
    }
    debugPrint("Nearest: $nearestResult");
    return nearestResult;
  }

  bool isFloor(ScanResult scanResult) =>
      scanResult.advertisementData.serviceUuids.contains(serviceGuids[0]);

  int charIndex = 0;

// Discover services and characteristics after connecting
  @override
  void listenCharacteristics(
      final BluetoothDevice bleDevice,
      final BluetoothService bleService,
      final CharacteristicCallback callback) async {
    floorService = bleService;
    _timerForChar?.cancel();
    _timerForChar = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (bleDevice.isDisconnected) {
        debugPrint("Disconnected Device");
        _timerForChar?.cancel();
        return;
      }

      // debugPrint("Charas: ${bleService.characteristics.length}");

      bool areEqual(List<int> list1, List<int>? list2) {
        if (list1.length != list2?.length) {
          return false;
        }
        for (int i = 0; i < list1.length; i++) {
          if (list1[i] != list2?[i]) {
            return false;
          }
        }
        return true;
      }

      void floorChange(List<int> event) {
        if (event.isEmpty) return;
        debugPrint("floorChange: $event");

        // if(areEqual(event, floorChangeData)) {
        //   debugPrint("Same Data");
        //   return;
        // }

        floorChangeData = event;

        String carFloor = ((event[0] & 0x3F)).toString();
        debugPrint("Car Floor: $carFloor");

        callback.floorChange(int.parse(carFloor));

        if ((event[0] & 0x40) == 0x40) {
          debugPrint("PresenceOfLight: true");
          callback.light(true);
        } else {
          debugPrint("PresenceOfLight: false");
          callback.light(true);
        }

        if ((event[1] & 0x1) == 0x1) {
          if ((event[1] & 0x02) == 0x02) {
            debugPrint("CarDirection = Direction.Up");
            callback.movement(Direction.up);
          } else {
            debugPrint("CarDirection = Direction.Down");
            callback.movement(Direction.down);
          }
        } else {
          debugPrint("CarDirection = Direction.Stopped");
          callback.movement(Direction.stopped);
        }
      }

      if(charIndex == 0) {
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

      // mission Status Characteristic data
      void missionStatus(List<int> event) {
        if (event.isEmpty) return;
        debugPrint("Mission Stat: $event");

        // if(areEqual(event, missionStateData)) {
        //   debugPrint("Same Data");
        //   return;
        // }

        missionStateData = event;

        if (event.length > 2) {
          var missionStatus = event[0];
          var eta = event[1] * 256 + event[2];

          debugPrint("Mission Stat: $missionStatus, ETA: $eta");
          callback.missionStatus(TypeMissionStatus.values[missionStatus], eta);
        }
      }

      if(charIndex == 1) {
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

      // out Of Service Characteristic data
      void outOfService(List<int> event) {
        if (event.isEmpty) return;
        debugPrint("OutOfService: $event");

        // if(areEqual(event, outOfServiceData)) {
        //   debugPrint("Same Data");
        //   return;
        // }

        outOfServiceData = event;

        if (event[0] == 0) {
          debugPrint("this.OutOfService = false;");
        } else {
          debugPrint("this.OutOfService = true;");
        }
      }

      if(charIndex == 2) {
        // debugPrint(outOfServiceCharacteristicGuid);
        var outOfServiceCharacteristic = bleService.characteristics
            .firstWhereOrNull((element) =>
        element.characteristicUuid.str == outOfServiceCharacteristicGuid);

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

      // Movement Direction Characteristic data
      // void movementDirection(List<int> event) {
      //   if (event.isEmpty) return;
      //   debugPrint("movementDirectionCar: $event");
      //
      //   if(areEqual(event, movementData)) {
      //     debugPrint("Same Data");
      //     return;
      //   }
      //
      //   movementData = event;
      //
      //   if ((event[0] & 0x1) == 0x1) {
      //     if ((event[0] & 0x02) == 0x02) {
      //       debugPrint("CarDirection = Direction.Up");
      //     } else {
      //       debugPrint("CarDirection = Direction.Down");
      //     }
      //   } else {
      //     debugPrint("CarDirection = Direction.Stopped");
      //   }
      // }

      // var movementDirectionCharacteristic = bleService.characteristics
      //     .firstWhereOrNull((element) =>
      //         element.characteristicUuid.str == movementDirectionCar);

      // try {
      //   if (movementDirectionCharacteristic?.properties.read == true) {
      //     if(bleDevice.isConnected) {
      //       movementDirection(
      //           await movementDirectionCharacteristic?.read() ?? []);
      //     } else {
      //     debugPrint("Device Disconnect While Read Char");
      //   }
      //   }
      // } catch (e) {
      //   debugPrint("Read Char Error: $e");
      // }


      if(charIndex < 3) {
        charIndex++;
      } else {
        charIndex = 0;
      }

    });
  }

  void _scanDevices() {
    if (!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan(
          withServices: serviceGuids,
          timeout: const Duration(milliseconds: 1500),
          androidUsesFineLocation: false);
    }
  }

  Future<void> _stopScanDevices() {
    return FlutterBluePlus.stopScan();
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
  void connectToBleDevice(final ScanResult result, final Function callback) {
    if (result.device.isDisconnected) {
      result.device
          .connect(autoConnect: false, timeout: const Duration(seconds: 35));
      result.device.connectionState.listen((BluetoothConnectionState state) {
        debugPrint(state == BluetoothConnectionState.connected
            ? "BLE Device Connect"
            : "BLE Device Disconnect");
        if (result.device.isDisconnected) {
          devices.remove(result);
        }
        callback(state);
      });
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
}
