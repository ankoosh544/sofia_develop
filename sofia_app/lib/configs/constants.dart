import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const bool isTestingMode = true;
const bool isServiceGuid = true;

const FLOOR_SERVICE_GUID = "6c962546-6011-4e1b-9d8c-05027adb3a01";
const CAR_SERVICE_GUID = "6c962546-6011-4e1b-9d8c-05027adb3a02";
const ESP_SERVICE_GUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

final List<Guid> serviceGuids = [
  Guid(FLOOR_SERVICE_GUID), // FLOOR_SERVICE_GUID
  Guid(CAR_SERVICE_GUID), // CAR_SERVICE_GUID
  Guid(ESP_SERVICE_GUID), // ESP32
];

const periodicDuration = 3000; //milliseconds
const timeoutDuration = 120; //seconds

const deviceNameServiceId = '00001800-0000-1000-8000-00805f9b34fb';
const deviceName = '00002a00-0000-1000-8000-00805f9b34fb';

const floorrequestcharacteristicguid =
    "beb5483e-36e1-4688-b7f5-ea07361b26a8"; //used to send new target plans and priorities

const floorChangeCharacteristicGuid =
    "beb5483e-36e1-4688-b7f5-ea07361b26a9"; // send to the phone where the booth is

const missionStatusCharacteristicGuid =
    "beb5483e-36e1-4688-b7f5-ea07361b26aa"; // cabin on the destination floor7

const outOfServiceCharacteristicGuid =
    "beb5483e-36e1-4688-b7f5-ea07361b26ab"; // out of service lift default 0

const movementDirectionCar =
    "beb5483e-36e1-4688-b7f5-ea07361b26ac"; // movement and direction of the car
// byte 0 = 1 car moving
// byte 1 = 0 Car up
// byte 1 = 1 Car down
