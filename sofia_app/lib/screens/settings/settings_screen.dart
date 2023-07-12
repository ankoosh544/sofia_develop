import 'package:flutter/material.dart';

import '../../configs/index.dart';
import '../../widgets/index.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SofiaAppBar(
        title: tabSettings,
      ),
      body: Text('Settings'),
    );
  }
}
