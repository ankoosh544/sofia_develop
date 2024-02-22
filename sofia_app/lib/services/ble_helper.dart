import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia_app/interfaces/characteristic_callback.dart';

import '../enums/direction.dart';
import '../enums/type_mission_status.dart';
import '../interfaces/i_ble_helper.dart';
import '../models/ble/device_data.dart';

class BLEHelper implements IBLEHelper {
  static const FLOOR_SERVICE_GUID = "6C962546-6011-4E1B-9D8C-05027ADB3A01";
  static const CAR_SERVICE_GUID = "6C962546-6011-4E1B-9D8C-05027ADB3A02";

  static const floorRequestCharacteristicGuid =
      "BEB5483E-36E1-4688-B7F5-EA07361B26A8"; //used to send new target plans and priorities

  static const floorChangeCharacteristicGuid =
      "BEB5483E-36E1-4688-B7F5-EA07361B26A9"; // send to the phone where the booth is

  static const missionStatusCharacteristicGuid =
      "BEB5483E-36E1-4688-B7F5-EA07361B26AA"; // cabin on the destination floor7

  static const outOfServiceCharacteristicGuid =
      "BEB5483E-36E1-4688-B7F5-EA07361B26AB"; // out of service lift default 0

  static const movementDirectionCar =
      "BEB5483E-36E1-4688-B7F5-EA07361B26AC"; // movement and direction of the car
// byte 0 = 1 car moving
// byte 1 = 0 Car up
// byte 1 = 1 Car down

  // static const ESP_SERVICE_GUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  final List<Guid> serviceGuids = [
    Guid(FLOOR_SERVICE_GUID), // FLOOR_SERVICE_GUID
    // Guid(CAR_SERVICE_GUID), // CAR_SERVICE_GUID
    // Guid(ESP_SERVICE_GUID), // ESP32
  ];

  ScanResult? oldNearestDevice;

  List<ScanResult> devices = [];

  final int _interval = const Duration(seconds: 2).inMilliseconds;
  Timer? _timer;

  BluetoothService? floorService;

  void addItem(ScanResult device) {
    int index = devices.indexWhere((item) => item == device);  // Check for existing object
    if (index != -1) {
      devices[index] = device;  // Replace existing object
    } else {
      devices.add(device);  // Add new object
    }
  }

  @override
  void scanNearestBleDevice(Function callback) async {
    // Start scanning

    _scanDevices();
    // Cancel any existing timer before starting a new one
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _interval), (timer) async {
      // Your periodic task to be executed here
      debugPrint("Executing task");
      // await _stopScanDevices();
      _scanDevices();
    });


    FlutterBluePlus.scanResults.listen((results) async {
      debugPrint("Scanning:");
      if (results.isEmpty) return;
      debugPrint("Results: ${results.toString()}");
      for(var result in results) {
        addItem(result);
      }
      print("Devices: ${devices.length}");
      var newNearestDevice = findNearestScanResult(devices);
      var rssi = (-newNearestDevice.rssi);
      print("rssi: $rssi");

        print("Device: ${newNearestDevice.device.platformName.codeUnits.toString()}");
      if (oldNearestDevice != newNearestDevice) {
        print("Changing");
        if (isFloor(newNearestDevice)) {
          //await oldNearestDevice?.device.disconnect();
          oldNearestDevice = newNearestDevice;
          callback(newNearestDevice.device);
        }
      }
    });
  }

  void _listenDeviceConnection(BluetoothDevice device, Function callback) {
    // listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      debugPrint(state == BluetoothConnectionState.connected
          ? "BLE Device Connect"
          : "BLE Device Disconnect");
      callback(state);
    });

// cleanup: cancel subscription when disconnected
// Note: `delayed:true` lets us receive the `disconnected` event in our handler
// Note: `next:true` means cancel on *next* disconnection. Without this, it
//   would cancel immediately because we're already disconnected right now.
    device.cancelWhenDisconnected(subscription, delayed: true, next: true);
  }

  ScanResult findNearestScanResult(List<ScanResult> scanResults) {
    ScanResult nearestResult = scanResults.first;
    for (ScanResult result in scanResults) {
      var rssi = -(result.rssi);
      print("RSSI: $rssi");
      if (rssi < -(nearestResult.rssi)) {
        // Smaller RSSI indicates closer proximity
        nearestResult = result;
      }
    }
    debugPrint("Nearest: $nearestResult");
    return nearestResult;
  }

  bool isFloor(ScanResult scanResult) =>
      scanResult.advertisementData.serviceUuids.contains(serviceGuids[0]);

// Discover services and characteristics after connecting
  @override
  void listenCharacteristics(BluetoothService bleService, CharacteristicCallback callback) async {
    floorService = bleService;
    // floor Change Characteristic data
    void floorChange(List<int> event) {
      if (event.isEmpty) return;
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

    var floorChangeCharacteristic = bleService.characteristics.firstWhereOrNull(
        (element) =>
            element.characteristicUuid.str.toUpperCase() ==
            floorChangeCharacteristicGuid);
    if(floorChangeCharacteristic?.properties.read == true) {
      floorChange(await floorChangeCharacteristic?.read() ?? []);
    }
    floorChangeCharacteristic?.setNotifyValue(true);

    floorChangeCharacteristic?.onValueReceived.listen((event) async {
      debugPrint("floorChangeCharacteristicGuid: $event");
      floorChange(event);
    });
  


    // mission Status Characteristic data
    void missionStatus(List<int> event) {
      if (event.isEmpty) return;
      if (event.length > 2) {
        var missionStatus = event[0];
        var eta = event[1] * 256 + event[2];

        debugPrint("Mission Stat: $missionStatus, ETA: $eta");
        callback.missionStatus(TypeMissionStatus.values[missionStatus], eta);
      }
    }

    var missionStatusCharacteristic = bleService.characteristics
        .firstWhereOrNull((element) =>
            element.characteristicUuid.str.toUpperCase() ==
            missionStatusCharacteristicGuid);
    
    if(missionStatusCharacteristic?.properties.read == true) {
      missionStatus(await missionStatusCharacteristic?.read() ?? []);
    }

    missionStatusCharacteristic?.setNotifyValue(true);
    missionStatusCharacteristic?.lastValueStream.listen((event) {
      debugPrint("missionStatusCharacteristicGuid: $event");
      missionStatus(event);
    });
  

    // out Of Service Characteristic data
    void outOfService(List<int> event) {
      if (event.isEmpty) return;

      if (event[0] == 0) {
        debugPrint("this.OutOfService = false;");
      } else {
        debugPrint("this.OutOfService = true;");
      }
    }
    var outOfServiceCharacteristic = bleService.characteristics
        .firstWhereOrNull((element) =>
            element.characteristicUuid.str.toUpperCase() ==
            outOfServiceCharacteristicGuid);
    
    if(outOfServiceCharacteristic?.properties.read == true) {
      outOfService(await outOfServiceCharacteristic?.read() ?? []);
    }
    outOfServiceCharacteristic?.setNotifyValue(true);
    outOfServiceCharacteristic?.lastValueStream.listen((event) {
      debugPrint("outOfServiceCharacteristicGuid: $event");
      outOfService(event);
    });
  

    // Movement Direction Characteristic data
    void movementDirection(List<int> event) {
      if (event.isEmpty) return;

      debugPrint("movementDirectionCar: $event");
      if ((event[0] & 0x1) == 0x1) {
        if ((event[0] & 0x02) == 0x02) {
          debugPrint("CarDirection = Direction.Up");
        } else {
          debugPrint("CarDirection = Direction.Down");
        }
      } else {
        debugPrint("CarDirection = Direction.Stopped");
      }
    }
    var movementDirectionCharacteristic = bleService.characteristics
        .firstWhereOrNull((element) =>
            element.characteristicUuid.str.toUpperCase() ==
            movementDirectionCar);
    
    if(movementDirectionCharacteristic?.properties.read == true) {
      movementDirection(await movementDirectionCharacteristic?.read() ?? []);
    }
    movementDirectionCharacteristic?.setNotifyValue(true);
    movementDirectionCharacteristic?.lastValueStream.listen((event) {
      movementDirection(event);
    });
    
  }

  void _scanDevices() {
    if(!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan(
          withServices: serviceGuids,
          timeout: const Duration(milliseconds: 120),
          androidUsesFineLocation: false);
    }
  }

  Future<void> _stopScanDevices() {
    return FlutterBluePlus.stopScan();
  }

  @override
  void writeFloor(int floor) {
    BluetoothCharacteristic? floorRequestCharacteristic =
        floorService?.characteristics.firstWhereOrNull((element) =>
            element.uuid.str.toUpperCase() == floorRequestCharacteristicGuid);

    debugPrint("writeFloor: $floorRequestCharacteristic");

    floorRequestCharacteristic?.write([floor, 0]);
  }

  @override
  void connectToBleDevice(BluetoothDevice device, Function callback) async {
    await device.connect(autoConnect: false, timeout: const Duration(seconds: 35));
    _listenDeviceConnection(device, (state) {
      callback(state);
    });
  }

  @override
  void bluetoothOnOff(Function callback) {
    // handle bluetooth on & off
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      debugPrint(" Bluetooth State: $state");
      callback(state);
    });
  }
}
