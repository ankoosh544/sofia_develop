import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/ble/device_data.dart';
import '../models/ble/service_data.dart';

class BLEHelper {
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

  DeviceData? deviceData;
  ScanResult? oldNearestDevice;

  final int _interval = const Duration(milliseconds: 10000).inMilliseconds;
  Timer? _timer;

  void startScanning() async {
    // Start scanning

    scanDevices();
    // Cancel any existing timer before starting a new one
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _interval), (timer) async {
      // Your periodic task to be executed here
      debugPrint("Executing task");
      await stopScanDevices();
      scanDevices();
    });

    FlutterBluePlus.scanResults.listen((results) async {
      debugPrint("Scanning:");
      if (results.isEmpty) return;
      debugPrint("Results: ${results.toString()}");
      var newNearestDevice = findNearestScanResult(results);
      if (oldNearestDevice != newNearestDevice) {
        await oldNearestDevice?.device.disconnect();
        if (isFloor(newNearestDevice)) {
          oldNearestDevice = newNearestDevice;

          await newNearestDevice.device.connect(autoConnect: true, mtu: null);

          listenDeviceConnection(newNearestDevice.device);
        }
      }
    });
  }

  void listenDeviceConnection(BluetoothDevice device) {
    // listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        debugPrint("Disconnect");
      } else {
        debugPrint("Connect");
        discoverServices(device);
      }
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
      if (-(result.rssi) < -(nearestResult.rssi)) {
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
  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    // var characteristics = services.firstOrNull?.characteristics;

    deviceData = DeviceData(device,
        services.map((e) => ServiceData(e, e.characteristics)).toList());

    listenCharacteristics(services);

    // if (characteristics != null) {
    //   for (BluetoothCharacteristic c in characteristics) {
    //     c.setNotifyValue(true); // Listen for value changes
    //     c.lastValueStream.listen((data) {
    //       // Handle characteristic value changes here
    //       debugPrint('Characteristic ${c.uuid.toString()} changed: $data');
    //     });
    //   }
    // }
  }

  Future<void> scanDevices() {
    return FlutterBluePlus.startScan(
        withServices: serviceGuids,
        timeout: const Duration(milliseconds: 15000),
        androidUsesFineLocation: false,
        androidScanMode: AndroidScanMode.lowLatency);
  }

  Future<void> stopScanDevices() {
    return FlutterBluePlus.stopScan();
  }

  void writeFloor(String floor) {
    BluetoothService? myService = deviceData?.bluetoothServices
        .firstWhereOrNull((service) =>
            service.bluetoothService.uuid.str.toUpperCase() ==
            FLOOR_SERVICE_GUID)
        ?.bluetoothService;

    BluetoothCharacteristic? floorRequestCharacteristic =
        myService?.characteristics.firstWhereOrNull((element) =>
            element.uuid.str.toUpperCase() == floorRequestCharacteristicGuid);

    debugPrint("writeFloor: $floorRequestCharacteristic");

    floorRequestCharacteristic?.write([int.parse(floor), 0]);
  }

  void listenCharacteristics(List<BluetoothService> services) {
    BluetoothService? myService = services.firstWhereOrNull(
        (service) => service.uuid.str.toUpperCase() == FLOOR_SERVICE_GUID);

    // floor Change Characteristic data
    var floorChangeCharacteristic = myService?.characteristics.firstWhereOrNull(
        (element) =>
            element.characteristicUuid.str.toUpperCase() ==
            floorChangeCharacteristicGuid);
    floorChangeCharacteristic?.setNotifyValue(true);
    floorChangeCharacteristic?.lastValueStream.listen((event) {
      debugPrint("floorChangeCharacteristicGuid: $event");

      if(event.isEmpty) return;

      String carFloor = ((event[0] & 0x3F)).toString();
      debugPrint("Car Floor: $carFloor");

      if ((event[0] & 0x40) == 0x40) {
        debugPrint("PresenceOfLight: true");
      } else {
        debugPrint("PresenceOfLight: false");
      }

      if ((event[1] & 0x1) == 0x1) {
        if ((event[1] & 0x02) == 0x02) {
          debugPrint("CarDirection = Direction.Up");
        } else {
          debugPrint("CarDirection = Direction.Down");
        }
      } else {
        debugPrint("CarDirection = Direction.Stopped");
      }
    });

    // mission Status Characteristic data
    var missionStatusCharacteristic = myService?.characteristics
        .firstWhereOrNull((element) =>
            element.characteristicUuid.str.toUpperCase() ==
            missionStatusCharacteristicGuid);
    missionStatusCharacteristic?.setNotifyValue(true);
    missionStatusCharacteristic?.lastValueStream.listen((event) {
      debugPrint("missionStatusCharacteristicGuid: $event");

      if(event.isEmpty) return;

      if (event.length > 2) {
        var missionStatus = event[0];
        var eta = event[1] * 256 + event[2];

        debugPrint("Mission Stat: $missionStatus, ETA: $eta");
      }
    });

    // out Of Service Characteristic data
    var outOfServiceCharacteristic = myService?.characteristics
        .firstWhereOrNull((element) =>
            element.characteristicUuid.str.toUpperCase() ==
            outOfServiceCharacteristicGuid);
    outOfServiceCharacteristic?.setNotifyValue(true);
    outOfServiceCharacteristic?.lastValueStream.listen((event) {
      debugPrint("outOfServiceCharacteristicGuid: $event");

      if(event.isEmpty) return;

      if (event[0] == 0) {
        debugPrint("this.OutOfService = false;");
      } else {
        debugPrint("this.OutOfService = true;");
      }
    });

    // Movement Direction Characteristic data
    var movementDirectionCharacteristic = myService?.characteristics
        .firstWhereOrNull((element) =>
            element.characteristicUuid.str.toUpperCase() ==
            movementDirectionCar);
    movementDirectionCharacteristic?.setNotifyValue(true);
    movementDirectionCharacteristic?.lastValueStream.listen((event) {

      if(event.isEmpty) return;

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
    });

    writeFloor("3");
  }
}
