class BLESample {
  String deviceId;
  // BleDeviceType deviceType;
  String alias;
  DateTime timestamp;
  int? txPower;
  int? rxPower;

  BLESample({
    required this.deviceId,
    // required this.deviceType,
    required this.alias,
    required this.timestamp,
    this.txPower,
    this.rxPower,
  });

  @override
  String toString() {
    return 'BLESample{'
        'deviceId: $deviceId, '
        // 'deviceType: $deviceType, '
        'alias: $alias, '
        'timestamp: $timestamp, '
        'txPower: $txPower, '
        'rxPower: $rxPower'
        '}';
  }
}
