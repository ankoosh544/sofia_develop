import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../widgets/widget_tiles.dart';
import 'index.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            onPressed: Platform.isAndroid
                ? () => FlutterBluePlus.instance.turnOff()
                : null,
            child: const Text('TURN OFF'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 2))
                  .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: snapshot.data!.map((device) {
                    log('Psk : ${device.toString()}');
                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(device.id.toString()),
                      trailing: StreamBuilder<BluetoothDeviceState>(
                        stream: device.state,
                        initialData: BluetoothDeviceState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data == BluetoothDeviceState.connected) {
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
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.instance.scanResults,
              initialData: const [],
              builder: (c, snapshot) {
                return snapshot.hasData
                    ? Column(
                        children: snapshot.data!.map(
                          (result) {
                            log('Psk 1 ${result.toString()}');
                            return ScanResultTile(
                              result: result,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    result.device.connect();
                                    return DeviceScreen(device: result.device);
                                  },
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
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
    );
  }
}
