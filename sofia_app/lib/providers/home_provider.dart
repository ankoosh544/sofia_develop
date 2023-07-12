import 'package:flutter/material.dart';
import 'package:sofia_app/configs/app_strings.dart';

class HomeProvider extends ChangeNotifier {
  String _title = tabHome;
  String get title => _title;

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }
}
