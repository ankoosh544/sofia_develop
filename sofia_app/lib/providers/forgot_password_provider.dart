import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  String _email = '';
  bool _isButtonActive = false;

  bool get isButtonActive => _isButtonActive;

  set isButtonActive(bool value) {
    _isButtonActive = value;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!_isValidEmail(value)) {
      return 'Invalid email format';
    }
    return '';
  }

  bool _isValidEmail(String email) {
    final emailRegex = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }
}
