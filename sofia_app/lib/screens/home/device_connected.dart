import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/configs/index.dart';
import 'package:sofia_app/providers/index.dart';

import 'device_screen.dart';

class DeviceConnected extends StatelessWidget {
  const DeviceConnected({Key? key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.read<BleProvider>();
    final scanResults = bleProvider.scanResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text(tabHome),
        notificationPredicate: (notification) => notification.depth == 1,
        scrolledUnderElevation: 4.0,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(size_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              welcomeMessage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: size_16,
            ),
            Text(
              greetingMessage,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: size_16,
            ),
            Text(
              sourceFrom,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: size_16,
            ),
            Container(
              width: MediaQuery.sizeOf(context).height * .09,
              height: MediaQuery.sizeOf(context).height * .09,
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '1',
                    style: TextStyle(fontSize: 38, color: Colors.white),
                  ),
                ],
              ),
            ),
            Text(
              sourceTo,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: size_16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 100),
              child: TextFormField(
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                  ),
                  hintText: hintDestination,
                  hintStyle: TextStyle(fontSize: 20, color: Colors.blueGrey),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                style: const TextStyle(fontSize: 30, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(
              height: size_20,
            ),
            Text(
              warningAttention,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.orange),
            ),
            StreamBuilder<List<BluetoothDevice>>(
              stream: context.read<BleProvider>().connectedDeviceStream,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: snapshot.data!.map((device) {
                    log('Psk : ${device.toString()}');
                    return ListTile(
                      title: Text(device.localName),
                      subtitle: Text(device.remoteId.toString()),
                      trailing: StreamBuilder<BluetoothConnectionState>(
                        stream: device.connectionState,
                        initialData: BluetoothConnectionState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data ==
                              BluetoothConnectionState.connected) {
                            return ElevatedButton(
                              child: const Text('OPEN'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DeviceScreen(device: device),
                                ),
                              ),
                            );
                          }
                          return Text(snapshot.data.toString());
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
