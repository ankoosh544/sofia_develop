import '../enums/direction.dart';
import '../enums/type_mission_status.dart';

abstract class CharacteristicCallback {
  void floorChange(int floor);

  void light(bool present);

  void movement(Direction direction);

  void serviceStatus(bool outOfService);

  void missionStatus(TypeMissionStatus status, int eta);
}
