import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../configs/index.dart';
import '../widgets/widget_tiles.dart';
import 'index.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBluePlus.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Find Devices',
                        style: textStyle,
                      ),
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
                  const Divider(
                    thickness: 2,
                    color: Colors.lightBlue,
                  ),
                  StreamBuilder<List<BluetoothDevice>>(
                    stream: Stream.periodic(const Duration(seconds: 2))
                        .asyncMap(
                            (_) => FlutterBluePlus.instance.connectedDevices),
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
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
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
                                          return DeviceScreen(
                                              device: result.device);
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
          );
        }
        return BluetoothOffScreen(state: state);
      },
    );
  }
}
