// settings_model.dart
import 'package:floor/floor.dart';
import 'package:sofia_app/models/user.dart';

@Entity(
  tableName: 'settings',
  foreignKeys: [
    ForeignKey(
      childColumns: ['userId'],
      parentColumns: ['id'],
      entity: User,
      // onDelete: ForeignKeyAction.CASCADE,
    ),
  ],
)
class Settings {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final int userId; // Foreign key to User table
  final bool darkModeEnabled;
  final String language;

  Settings(this.id, this.userId, this.darkModeEnabled, this.language);
}
