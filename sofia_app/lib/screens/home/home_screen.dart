import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/screens/emergency_contacts/emergency_contacts_screen.dart';
import 'package:sofia_app/providers/ble_provider.dart';
import 'package:sofia_app/providers/profile_provider.dart';
import 'package:sofia_app/providers/settings_provider.dart';
import 'package:sofia_app/screens/profile/profile_screen.dart';
import 'package:sofia_app/screens/settings/settings_screen.dart';

import '../../configs/index.dart';
import 'device_connected.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BleProvider>().connectToNearestDevice();
    return DefaultTabController(
      initialIndex: 0,
      length: tabsCount,
      child: Scaffold(
        backgroundColor: Colors.teal,
        bottomNavigationBar: TabBar(
          tabs: <Widget>[
            _buildTab(
              const Icon(
                Icons.home_filled,
              ),
              titles[0],
            ),
            _buildTab(
              const Icon(
                Icons.settings,
              ),
              titles[1],
            ),
            _buildTab(
              const Icon(
                Icons.account_circle_rounded,
              ),
              titles[2],
            ),
            // if (isTestingMode)
            //   _buildTab(
            //     const Icon(Icons.account_tree),
            //     titles[3],
            //   ),
            _buildTab(
              const Icon(
                Icons.account_circle_rounded,
              ),
              titles[4],
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            ChangeNotifierProvider(
              create: (_) => ProfileProvider()..init(),
              child: const DeviceConnected(),
            ),
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(),
              child: const SettingsScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider()..init(),
              child: const ProfileScreen(),
            ),
            EmergencyContactsScreen(),
          ],
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBluePlus.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data ?? false) {
              return FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () async {
                  try {
                    FlutterBluePlus.stopScan();
                  } catch (e) {}
                },
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: const Icon(Icons.search),
                  onPressed: () async {
                    try {
                      // context.read<BleProvider>().startScanning();
                    } catch (e) {}
                  });
            }
          },
        ),
      ),
    );
    // );
  }

  Tab _buildTab(Icon icon, String title) => Tab(
        icon: Icon(
          icon.icon,
          color: Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconMargin: const EdgeInsets.only(bottom: 6.0),
      );
}
