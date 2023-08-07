import 'package:floor/floor.dart';

import '../user/user.dart';

@Entity(
  tableName: 'settings',
  foreignKeys: [
    ForeignKey(
      childColumns: ['user_id'],
      parentColumns: ['id'],
      entity: User,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class Settings {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'user_id')
  final int userId;
  @ColumnInfo(name: 'dark_mode')
  final bool darkMode;
  final String language;

  Settings(
    this.id,
    this.userId,
    this.darkMode,
    this.language,
  );
}
