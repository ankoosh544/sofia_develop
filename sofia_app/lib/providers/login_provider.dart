import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/databases/app_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:sofia_app/providers/auth_provider.dart';
import 'package:sofia_app/screens/password/forgot_password_screen.dart';
import 'package:sofia_app/screens/registration/registration_screen.dart';

class LoginProvider with ChangeNotifier {
  late final UserDao userDao;
  String username = '';
  String password = '';
  bool rememberMe = false;
  final _storage = FlutterSecureStorage();
  final _rememberMeKey = 'rememberMe';
  final _usernameKey = 'username';
  final _passwordKey = 'password';
  bool isPasswordVisible = false;

  void setUsername(String value) {
    username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void toggleVisiblePassword() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    // Get the UserDao instance
    final userDao = database.userDao;
    // Fetch the user from the database based on the username
    final user = await userDao.getUserByUsername(username);
    if (user != null && user.password == password) {
      //check rememberMe Flag
      if (rememberMe) {
        // Save user credentials in secure storage
        await _storage.write(key: _rememberMeKey, value: 'true');
        await _storage.write(key: _usernameKey, value: username);
        await _storage.write(key: _passwordKey, value: password);
      } else {
        // Clear the user credentials from secure storage
        await _storage.delete(key: _rememberMeKey);
        await _storage.delete(key: _usernameKey);
        await _storage.delete(key: _passwordKey);
      }

      Provider.of<AuthProvider>(context, listen: false)
          .login(username, password);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Failed login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid username or password.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    // Close the database
    await database.close();
  }

  void forgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(),
      ),
    );
  }

  void registerUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(),
      ),
    );
  }
}
