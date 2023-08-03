import 'package:flutter/material.dart';

import '../../configs/index.dart';

class CarStatusScreen extends StatelessWidget {
  const CarStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(carStatus),
      ),
      body: Padding(
        padding: const EdgeInsets.all(size_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(carPosition),
                    Text(zeroFloor),
                  ],
                ),
                Icon(
                  Icons.home,
                  size: 40,
                ),
              ],
            ),
            Text(etaToFloor3),
            Text(warningAttention),
            Text(estimatedTime),
            ElevatedButton(onPressed: () {}, child: Text(changeDestination)),
            Text(warningAttention),
          ],
        ),
      ),
    );
  }
}
