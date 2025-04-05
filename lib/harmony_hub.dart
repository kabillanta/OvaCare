import 'package:flutter/material.dart';
import 'relaxation_room.dart';
import 'meditation.dart';
import 'yoga_coach.dart';

class HarmonyHubPage extends StatelessWidget {
  const HarmonyHubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Harmony Hub',
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
                Image.asset('assets/images/harmony_hub.png', height: 150),
                const SizedBox(height: 20),
                const Text(
                  'Balance Your Mind, Body & Soul!" ✨💆‍♀️💖',
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
                        'Meditations',
                        const Color.fromARGB(255, 74, 98, 138),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeditationPage()),
                          );
                        },
                      ),
                      _buildButton(
                        context,
                        'Relaxation Rooms',
                        const Color.fromARGB(255, 91, 120, 171),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RelaxationRoomPage()),
                          );
                        },
                      ),
                      _buildButton(
                        context,
                        'Yoga Coach',
                        const Color.fromARGB(255, 116, 153, 216),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => YogaCoachPage()),
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
