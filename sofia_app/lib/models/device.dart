import 'dart:core';

import 'package:sofia_app/enums/ble_device_type.dart';

class Device {
  String deviceId;
  BleDeviceType deviceType;
  String alias;
  DateTime timestamp;
  double? txPower;
  double? rxPower;

  Device({
    required this.deviceId,
    required this.deviceType,
    required this.alias,
    required this.timestamp,
    this.txPower,
    this.rxPower,
  });

  @override
  String toString() {
    return 'Device{'
        'deviceId: $deviceId, '
        'deviceType: $deviceType, '
        'alias: $alias, '
        'timestamp: $timestamp, '
        'txPower: $txPower, '
        'rxPower: $rxPower'
        '}';
  }
}
