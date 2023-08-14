import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/index.dart';
import 'package:sofia_app/screens/home/device_connected.dart';

void main() {
  const String userName = 'Test User Name';
  const String emailId = 'testing@gmail.com';

  testWidgets('Device Connected Screen - ', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ListenableProvider<BleProvider>(
              create: (_) => BleProvider(
                BleImpl(),
              ),
            ),
            ListenableProvider<ProfileProvider>(
              create: (_) => ProfileProvider()
                ..username = userName
                ..emailId = emailId,
            ),
          ],
          child: const DeviceConnected(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    //expect(find.text('Welcome'), findsOneWidget);
  });
}
