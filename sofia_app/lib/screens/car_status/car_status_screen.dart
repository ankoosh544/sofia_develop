import 'package:flutter/material.dart';
import '../../configs/index.dart';

class CarStatusScreen extends StatelessWidget {
  const CarStatusScreen({Key? key}) : super(key: key);
  final inProgress = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(carStatus),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to previous screen
          },
        ),
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
                    Text(
                      carPosition,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      zeroFloor,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_upward,
                  size: 40,
                  color: Colors.blue,
                ),
                Icon(
                  Icons.arrow_downward,
                  size: 40,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: inProgress
                  ? const Text(
                      "In Progress of Destination Floor Data ") // Show a progress indicator if inProgress is true
                  : const Text(
                      etaToFloor3,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: inProgress
                  ? const Text("Inprogress")
                  : const Text(
                      warningAttention,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: inProgress
                  ? const Text(
                      "Inprogress of Estimated time for Destination floor")
                  : const Text(
                      estimatedTime,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Center(
              child: inProgress
                  ? const Text("Inprogress of change Destination button")
                  : ElevatedButton(
                      onPressed: () {
                        // Navigator.of(context).pushReplacement(
                        //   MaterialPageRoute(builder: (context) => HomeScreen()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        changeDestination,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Center(
              child: inProgress
                  ? const Text("Inprogress of Warings Messages")
                  : const Text(
                      warningAttention,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
