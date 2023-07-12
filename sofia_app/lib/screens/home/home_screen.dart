import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/home_provider.dart';
import 'package:sofia_app/providers/profile_provider.dart';
import 'package:sofia_app/providers/settings_provider.dart';
import 'package:sofia_app/providers/testing_provider.dart';
import 'package:sofia_app/screens/profile/profile_screen.dart';
import 'package:sofia_app/screens/settings/settings_screen.dart';
import 'package:sofia_app/screens/testing/testing_screen.dart';

import '../../configs/index.dart';
import '../index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: tabsCount,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: Colors.white,
          child: TabBar(
            tabs: <Widget>[
              _buildTab(
                const Icon(Icons.home_filled),
                titles[0],
              ),
              _buildTab(
                const Icon(Icons.settings),
                titles[1],
              ),
              _buildTab(
                const Icon(Icons.account_circle_rounded),
                titles[2],
              ),
              if (showTestingMenu)
                _buildTab(
                  const Icon(Icons.account_tree),
                  titles[3],
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            const FindDevicesScreen(),
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(),
              child: const SettingScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(),
              child: const ProfileScreen(),
            ),
            if (showTestingMenu)
              ChangeNotifierProvider(
                create: (_) => TestingProvider(),
                child: const TestingScreen(),
              ),
          ],
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBluePlus.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                onPressed: () => context.read<HomeProvider>().stopScan(),
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              );
            } else {
              return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => context.read<HomeProvider>().periodicScan(),
              );
            }
          },
        ),
      ),
    );
  }

  Tab _buildTab(Icon icon, String title) => Tab(
        icon: icon,
        text: title,
        iconMargin: const EdgeInsets.only(bottom: 6.0),
      );
}
