import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:rxdart/rxdart.dart';
import 'package:sofia_app/enums/direction.dart';
import 'package:sofia_app/enums/operation_mode.dart';
import 'package:sofia_app/enums/type_mission_status.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sofia_app/interfaces/i_ble.dart';
import 'package:sofia_app/models/BLESample.dart';
import '../configs/index.dart';

class BleProvider extends ChangeNotifier {
  final IBle ble;
  final _connectedDevice = BehaviorSubject<List<BluetoothDevice>>.seeded([]);
  Stream<List<BluetoothDevice>> get connectedDeviceStream =>
      _connectedDevice.stream;
  final _myScanResults = BehaviorSubject<List<ScanResult>>.seeded([]);
  Stream<List<ScanResult>> get myScanResults => _myScanResults.stream;

  final _bluetoothState = BehaviorSubject<BluetoothAdapterState>.seeded(
      BluetoothAdapterState.unknown);
  Stream<BluetoothAdapterState> get bluetoothStateStream =>
      _bluetoothState.stream;
  BluetoothAdapterState get bluetoothState => _bluetoothState.value;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool outOfService = false;
  bool presenceOfLight = false;
  String carFloor = "--";
  Direction carDirection = Direction.stopped;
  TypeMissionStatus missionStatus = TypeMissionStatus.missionNoInit;
  int eta = -1;
  late OperationMode operationMode;

  BleProvider(this.ble) {
    // Initialize local notifications
    initializeNotifications();
    _getBluetoothState();
    //ble.startScanningAsync(5);

    ble.scanResults.listen((_) async {
      final nearestDevice = await ble.nearestDevice;
      if (await ble.connectionState != BluetoothConnectionState.connected &&
          (await ble.nearestScan).advertisementData.connectable) {
        await ble.connect(autoConnect: true);
        log('Device connected ----------->>  ${nearestDevice.remoteId.str}');
        await showNotification(
            'Connected to ${nearestDevice.localName} ${nearestDevice.remoteId.str}}');

        //await ble.discoverServices();
        await readCharacteristic(nearestDevice);
        await removedAllConnectedDevice();
      }
    });
  }

//   void periodicScan() {
//  _subscription = Stream.periodic(const Duration(seconds: 2), (_) => _)
//      .listen((_) => startScan());
//  }

  void initializeNotifications() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showNotification(String message) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'test_channel_id',
      'Test_Channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Bluetooth Notification Testig',
      message,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  void _getBluetoothState() => ble.adapterState.listen((event) {
        if (event == BluetoothAdapterState.on) {
          startScanning();
        } else {
          stopScan();
        }
        _bluetoothState.add(event);
      });

  void startScanning() async {
    if (ble.isScanningNow == false) {
      await ble.startScan(
        withServices: isServiceGuid ? serviceGuids : [],
        timeout: const Duration(days: timeoutDuration),
        androidUsesFineLocation: false,
      );
    }
  }

  void stopScan() async {
    await ble.stopScan();
    _refresh();
    await removedAllConnectedDevice();
  }

  void _refresh() {
    _myScanResults.add([]);
    _connectedDevice.add([]);
  }

  Future<void> readCharacteristic(nearestDevice) async {
    Stream.periodic(const Duration(seconds: 3), (_) => _).listen((e) async {
      print('Running every 5 seconds ...............');
      try {
        final connection =
            await (await ble.nearestDevice).connectionState.first;
        if (connection == BluetoothConnectionState.connected) {
          final services = await (await ble.nearestDevice).discoverServices();
          for (var service in services) {
            var characteristics = service.characteristics;
            for (BluetoothCharacteristic c in characteristics) {
              if (c.properties.read) {
                var data = await c.read();
                if (c.characteristicUuid.toString() == deviceName) {
                  print('PSK last value: ${String.fromCharCodes(data)}');
                  final device = await ble.nearestDevice;
                  final myDevice = BluetoothDevice.fromId(
                    device.remoteId.str,
                    localName: String.fromCharCodes(c.lastValue),
                    type: device.type,
                  );
                  setConnectedDevice(myDevice);
                }
                bleServiceOnCharacteristicUpdated(c);
              }
            }
          }
        }
      } catch (e) {
        log(e.toString());
      }
    });
  }

  Future<void> writeCharacteristic(String floor) async {
    try {
      if (floor.isNotEmpty) {
        final services = await (await ble.nearestDevice).discoverServices();
        for (var service in services) {
          var characteristics = service.characteristics;
          for (BluetoothCharacteristic c in characteristics) {
            if (c.properties.write) {
              if (c.characteristicUuid.toString() ==
                  floorRequestCharacteristicGuid) {
                await c.write(floor.codeUnits);
                print(
                    'Data written : ${String.fromCharCodes(floor.codeUnits)}');
              }
              // bleServiceOnCharacteristicUpdated(c);
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> bleServiceOnCharacteristicUpdated(
      BluetoothCharacteristic e) async {
    try {
      print("*****This is working ********$e");
      print(e.characteristicUuid.toString());
      print("=============");
      switch (e.characteristicUuid.toString()) {
        case floorChangeCharacteristicGuid:
          print("*******Case 1 Floor Change CharacteristicGuid***********");
          //print(e.lastValue);
          //print(String.fromCharCodes(e.lastValue));
          try {
            print(e.lastValue[0]);
            print("shek");
            carFloor = (e.lastValue[0] & 0x3F).toString();

            print("********************************$carFloor");

            if ((e.lastValue[0] & 0x40) == 0x40) {
              presenceOfLight = true;
              print("presenceofLight is true");
            } else {
              presenceOfLight = false;
              print("presenceofLight is false");
            }

            print(presenceOfLight.toString());
            print(presenceOfLight.toString());

            if ((e.lastValue[1] & 0x1) == 0x1) {
              if ((e.lastValue[1] & 0x02) == 0x02) {
                carDirection = Direction.up;
              } else {
                carDirection = Direction.down;
              }
            } else {
              carDirection = Direction.stopped;
            }
            print(carDirection.toString());
            print(carDirection.toString());
          } catch (ex) {
            print("$ex");
          }
          break;

        case missionStatusCharacteristicGuid:
          print("********Case 2 MissionStatus*********");
          print(e.lastValue);
          print(String.fromCharCodes(e.lastValue));
          try {
            if (e.lastValue.length > 2) {
              missionStatus = TypeMissionStatus.values[e.lastValue[0]];
              print("***MissionStatus*********$missionStatus");
              eta = e.lastValue[1] * 256 + e.lastValue[2];

              print("********************eta time*******$eta");
            }
            // onMissionStatusChanged?.call();
          } catch (ex) {
            print("$ex");
          }
          break;

        case outOfServiceCharacteristicGuid:
          print("*********Case 3 Out-ofService**********");
          //print(e.lastValue);
          //print(String.fromCharCodes(e.lastValue));
          if (e.lastValue[0] == 0) {
            outOfService = false;
          } else {
            outOfService = true;
          }

          print(outOfService.toString());
          break;

        case movementDirectionCar:
          print("*******Case 4 Car Direction******+");
          //print(e.lastValue);
          //print(String.fromCharCodes(e.lastValue));
          if ((e.lastValue[0] & 0x1) == 0x1) {
            if ((e.lastValue[0] & 0x02) == 0x02) {
              carDirection = Direction.up;
            } else {
              carDirection = Direction.down;
            }
          } else {
            carDirection = Direction.stopped;
          }
          //print(e.lastValue);
          print("***************car direction");
          print(carDirection.toString());
          break;
        default:
          print("*******Default******+");
          break;
      }
    } catch (ex) {
      print(ex);
    }
    notifyListeners();
  }

  Future removedAllConnectedDevice() async {
    final connectedDevices = await ble.connectedSystemDevices;
    for (var device in connectedDevices) {
      if ((await ble.nearestDevice).remoteId.str != device.remoteId.str) {
        await device.disconnect();
      }
    }
  }

  void setConnectedDevice(BluetoothDevice device) {
    _connectedDevice.value.clear();
    _connectedDevice.add([device]);
  }

  void clearConnectedDevice() {
    _connectedDevice.value.clear();
  }

  Stream<int> rssiStream(BluetoothDevice device) async* {
    var isConnected = true;
    final subscription = device.connectionState.listen((state) {
      isConnected = state == BluetoothConnectionState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }

  int getFloorNumber(String inputString) {
    final RegExp regex = RegExp(r'\d+');
    final Match? match = regex.firstMatch(inputString);
    if (match != null) {
      final String numberAsString = match.group(0)!;
      return int.parse(numberAsString);
    }

    // Return a default value (e.g., 0) if no numeric portion is found in the string.
    return 0;
  }
}
