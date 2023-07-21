import 'package:floor/floor.dart';

@Entity(tableName: 'User')
class User {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'email')
  final String email;

  @ColumnInfo(name: 'username')
  final String username;

  @ColumnInfo(name: 'password')
  final String password;

  @ColumnInfo(name: 'rememberMe')
  final bool rememberMe;

  User(this.id, this.email, this.username, this.password,
      this.rememberMe); // Generated constructor
}
