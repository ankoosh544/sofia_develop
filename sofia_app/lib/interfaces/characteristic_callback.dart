import '../enums/direction.dart';
import '../enums/type_mission_status.dart';

abstract class CharacteristicCallback {
  void floorChange(int floor, bool light, Direction direction);

  void serviceStatus(bool outOfService);

  void missionStatus(TypeMissionStatus status, int eta);
}
