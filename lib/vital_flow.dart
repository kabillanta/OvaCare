import 'package:flutter/material.dart';
import 'cycle_tracker_page.dart';
import 'symptom_log_page.dart';
import 'wearable_vitals_page.dart';

class VitalFlowPage extends StatelessWidget {
  const VitalFlowPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VitalFlow',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // VitalFlow image asset (ensure you have an image at this path)
                Image.asset('assets/images/vitals_tracker_logo.png', height: 150),
                const SizedBox(height: 20),
                const Text(
                  'Monitor your cycles, log symptoms & track your vitals for better health insights!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'FunnelSans',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                IntrinsicWidth(
                  child: Column(
                    children: [
                      _buildButton(
                        context,
                        'Cycle Tracker',
                        const Color.fromARGB(255, 74, 98, 138),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CycleTrackerPage(),
                            ),
                          );
                        },
                      ),
                      _buildButton(
                        context,
                        'Symptom Log',
                        const Color.fromARGB(255, 91, 120, 171),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SymptomLogPage(),
                            ),
                          );
                        },
                      ),
                      _buildButton(
                        context,
                        'Wearable Vitals',
                        const Color.fromARGB(255, 116, 153, 216),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WearableVitalsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onTap) {
    return Container(
      width: 250, // Set a fixed width to ensure uniformity
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
