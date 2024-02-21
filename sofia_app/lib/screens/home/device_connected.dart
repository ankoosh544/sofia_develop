import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/configs/index.dart';
import 'package:sofia_app/custom/light_warning_message.dart';
import 'package:sofia_app/custom/out_of_service_message.dart';
import 'package:sofia_app/screens/car_status/car_status_screen.dart';

import '../../providers/ble_provider.dart';
import '../../providers/profile_provider.dart';

class DeviceConnected extends StatelessWidget {
  const DeviceConnected({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          tabHome,
          style: TextStyle(color: Colors.white),
        ),
        notificationPredicate: (notification) => notification.depth == 1,
        scrolledUnderElevation: 4.0,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(size_16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: size_16,
              ),
              Text(
                '$greetingMessage ${context.watch<ProfileProvider>().username}', // Add missing comma here
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),

              const SizedBox(
                height: size_16,
              ),
              const Text(
                sourceFrom,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: size_16,
              ),
              context.watch<BleProvider>().deviceConnected
                  ? Container(
                      width: MediaQuery.sizeOf(context).height * .09,
                      height: MediaQuery.sizeOf(context).height * .09,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Animate(
                            effects: const [FadeEffect(), ScaleEffect()],
                            child: Text(
                              context.watch<BleProvider>().bleDeviceName.toString(),
                              style: const TextStyle(
                                fontSize: 38,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  :
                  // context.read<BleProvider>().clearConnectedDevice();
                  const Positioned.fill(
                      child: Center(
                        child: ConnectionInProgress(),
                      ),
                    ),
              const SizedBox(
                height: size_16,
              ),
              const Text(
                sourceTo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: size_16,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 100),
                // decoration: const BoxDecoration(
                //   border: Border(
                //     bottom: BorderSide(
                //       color: Colors.blueAccent,
                //       width: 1,
                //     ),
                //   ),
                // ),
                child: Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).height * .09,
                    height: MediaQuery.sizeOf(context).height * .09,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: hintDestination,
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        contentPadding: EdgeInsets.only(left: 12, top: 5),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                      onFieldSubmitted: (value) {
                      context.read<BleProvider>().writeFloor(int.parse(value));
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CarStatusScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: size_20,
              ),
              if (!context.watch<BleProvider>().lightStatus)
                LightWarningMessage(message: warningAttentionforLight),
              const SizedBox(
                height: size_20,
              ),
              if (context.watch<BleProvider>().outOfService)
                OutOfServiceMessage(message: warningAttentionForOutOfService),
              // if (isTestingMode)
              //   StreamBuilder<List<BluetoothDevice>>(
              //     stream: context.read<BleProvider>().connectedDeviceStream,
              //     initialData: const [],
              //     builder: (c, snapshot) {
              //       return Column(
              //         children: snapshot.data!.map((device) {
              //           int floorNumber = context
              //               .read<BleProvider>()
              //               .getFloorNumber(device.localName);
              //           return ListTile(
              //             title: Text(floorNumber.toString()),
              //             subtitle: Text(device.remoteId.toString()),
              //             trailing: StreamBuilder<BluetoothConnectionState>(
              //               stream: device.connectionState,
              //               initialData: BluetoothConnectionState.disconnected,
              //               builder: (c, snapshot) {
              //                 if (snapshot.data ==
              //                     BluetoothConnectionState.connected) {
              //                   return ElevatedButton(
              //                     child: const Text('OPEN'),
              //                     onPressed: () => Navigator.of(context).push(
              //                       MaterialPageRoute(
              //                         builder: (context) =>
              //                             DeviceScreen(device: device),
              //                       ),
              //                     ),
              //                   );
              //                 }
              //                 return Text(snapshot.data.toString());
              //               },
              //             ),
              //           );
              //         }).toList(),
              //       );
              //     },
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionInProgress extends StatelessWidget {
  const ConnectionInProgress({Key? key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [FadeEffect(), ScaleEffect()],
      child: const Text(
        waitingForConnection,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
