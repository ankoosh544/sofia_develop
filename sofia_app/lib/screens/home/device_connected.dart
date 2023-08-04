import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/configs/index.dart';
import 'package:sofia_app/providers/index.dart';

import 'device_screen.dart';

class DeviceConnected extends StatelessWidget {
  const DeviceConnected({super.key});

  int getFloorNumber(String inputString) {
    final RegExp regex = RegExp(r'\d+');
    final Match? match = regex.firstMatch(inputString);
    if (match != null) {
      final String numberAsString = match.group(0)!;
      return int.parse(numberAsString);
    }

    // Return a default value (e.g., 0) if no numeric portion is found in the string.
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
            StreamBuilder<List<BluetoothDevice>>(
              stream: context.read<BleProvider>().connectedDeviceStream,
              initialData: const [],
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final device = snapshot.data!.first;

                  return StreamBuilder<BluetoothConnectionState>(
                    stream: device.connectionState,
                    initialData: BluetoothConnectionState.disconnected,
                    builder: (c, snapshot) {
                      if (snapshot.data == BluetoothConnectionState.connected) {
                        return Container(
                          width: MediaQuery.sizeOf(context).height * .09,
                          height: MediaQuery.sizeOf(context).height * .09,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.green),
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Animate(
                                effects: const [FadeEffect(), ScaleEffect()],
                                child: Text(
                                  getFloorNumber(device.localName).toString(),
                                  style: const TextStyle(
                                      fontSize: 38, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        context.read<BleProvider>().clearConnectedDevice();
                        return const ConnectionInProgress();
                      }
                    },
                  );
                } else {
                  return const ConnectionInProgress();
                }
              },
            ),
            const SizedBox(
              height: size_16,
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
            if (isTestingMode)
              StreamBuilder<List<BluetoothDevice>>(
                stream: context.read<BleProvider>().connectedDeviceStream,
                initialData: const [],
                builder: (c, snapshot) {
                  return Column(
                    children: snapshot.data!.map((device) {
                      log('Psk : ${device.toString()}');
                      int floor_number = getFloorNumber(device.localName);
                      return ListTile(
                        title: Text(floor_number.toString()),
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

class ConnectionInProgress extends StatelessWidget {
  const ConnectionInProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [FadeEffect(), ScaleEffect()],
      child: const Text('Waiting for connection'),
    );
  }
}
