import 'package:flutter/material.dart';
import 'package:sofia_app/database/app_database.dart';

import '../storage/local_store.dart';

class ProfileProvider extends ChangeNotifier {
  String username = '';
  String? emailId;

  Future<void> init() async {
    final userDao = await SofiaDatabase.userDao;
    final userId = await LocalStore.getValue(key: 'userId');
    print('----> $userId');
    final user = await userDao.getUserById(int.parse(userId ?? '0'));
    if (user != null) {
      username = user.username;
      emailId = user.email;
    }
    notifyListeners();
  }

  void logout() {
    // Update the authentication state
    //_isLoggedIn = false;
    //_loggedInUsername = null;
    print('Logout');

    //notifyListeners();
  }
}
