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
        appBar: AppBar(
          title: Consumer<HomeProvider>(
            builder: (_, provider, __) => Text(provider.title),
          ),
          notificationPredicate: (notification) => notification.depth == 1,
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          elevation: 1,
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: TabBar(
            onTap: (index) =>
                context.read<HomeProvider>().setTitle(titles[index]),
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
                onPressed: () => FlutterBluePlus.instance.stopScan(),
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              );
            } else {
              return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.instance.startScan(
                  timeout: const Duration(seconds: 10),
                ),
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
