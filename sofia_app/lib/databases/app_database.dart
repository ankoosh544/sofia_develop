import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/models/user.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart'; // Generated code will be in this file

@Database(version: 1, entities: [User])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}
