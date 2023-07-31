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
      body: Column(
        children: [
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

          // StreamBuilder<List<ScanResult>>(
          //   stream: scanResults,
          //   initialData: const [],
          //   builder: (c, snapshot) {
          //     final scanResults = snapshot.data ?? [];
          //     print("ScanResult******************");
          //     print(scanResults);
          //     return Column(
          //       crossAxisAlignment: CrossAxisAlignment.stretch,
          //       children: [
          //         if (scanResults.isNotEmpty)
          //           Padding(
          //             padding: const EdgeInsets.all(16.0),
          //             child: Text(
          //               'Welcome User!', // Replace 'User' with the actual user name or data
          //               style: Theme.of(context).textTheme.headlineMedium,
          //             ),
          //           ),
          //         Expanded(
          //           child: scanResults.isEmpty
          //               ? Center(
          //                   child: Text('No devices are connected'),
          //                 )
          //               : ListView.builder(
          //                   itemCount: scanResults.length,
          //                   itemBuilder: (context, index) {
          //                     final r = scanResults[index];
          //                     return Text(
          //                       '${r.device.localName}: ${r.rssi.toString()}',
          //                       style: TextStyle(fontSize: 20),
          //                     );
          //                   },
          //                 ),
          //         ),
          //       ],
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
