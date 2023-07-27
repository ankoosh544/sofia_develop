import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/configs/index.dart';
import 'package:sofia_app/providers/index.dart';

class DeviceConnected extends StatelessWidget {
  const DeviceConnected({super.key});

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
      body: Column(
        children: [
          Text(
            'Welcome User {}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          StreamBuilder<List<ScanResult>>(
            stream: context.read<BleProvider>().scanResult,
            initialData: const [],
            builder: (c, snapshot) => Column(
              children: (snapshot.data ?? [])
                  .map(
                    (r) => Text(
                      '${r.device.localName}: ${r.rssi.toString()}',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                  .toList(),
            ),
          ),
          // StreamBuilder<List<BluetoothDevice>>(
          //   stream: context.read<BleProvider>().connectedDeviceStream,
          //   initialData: const [],
          //   builder: (c, snapshot) {
          //     return Column(
          //       children: snapshot.data!.map((device) {
          //         log('Connected Device : ${device.toString()}');
          //         return Column(
          //           children: [
          //             ListTile(
          //               title: Text(device.localName),
          //               subtitle: Text(device.remoteId.toString()),
          //               trailing: StreamBuilder<BluetoothConnectionState>(
          //                 stream: device.connectionState,
          //                 initialData: BluetoothConnectionState.disconnected,
          //                 builder: (c, snapshot) {
          //                   if (snapshot.data ==
          //                       BluetoothConnectionState.connected) {
          //                     return StreamBuilder<int>(
          //                         stream: context
          //                             .read<BleProvider>()
          //                             .rssiStream(device),
          //                         builder: (context, snapshot) {
          //                           return Text(
          //                               snapshot.hasData
          //                                   ? '${snapshot.data}dBm'
          //                                   : '',
          //                               style: Theme.of(context)
          //                                   .textTheme
          //                                   .bodySmall);
          //                         });
          //                   }
          //                   return Text(snapshot.data.toString());
          //                 },
          //               ),
          //             ),
          //           ],
          //         );
          //       }).toList(),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
