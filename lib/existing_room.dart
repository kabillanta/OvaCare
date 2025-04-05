import 'package:flutter/material.dart';
import 'room1.dart'; // The existing room with music and image
import 'room2.dart'; // Zen drawing room
import 'room3.dart'; // Forest scene room
import 'room4.dart'; // Bubble tapping room
import 'room5.dart'; // Night sky room
import 'room6.dart'; // Ocean waves room

class ExistingRoomsPage extends StatelessWidget {
  const ExistingRoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Existing Relaxation Rooms',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'FunnelSans'),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose from available relaxation rooms to unwind and de-stress.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'FunnelSans'
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true, // To make the grid scrollable within the column
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8, // Adjusted for better tile proportions
                  ),
                  itemCount: 6, // The number of relaxation rooms
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the selected room
                        switch (index) {
                          case 0:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Room1()));
                            break;
                          case 1:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Room2()));
                            break;
                          case 2:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Room3()));
                            break;
                          case 3:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Room4()));
                            break;
                          case 4:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Room5()));
                            break;
                          case 5:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Room6()));
                            break;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.room,
                              size: 40,
                              color: const Color.fromARGB(255, 74, 98, 138),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getRoomName(index),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'FunnelSans'
                              ),
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              child: Text(
                                _getRoomDescription(index),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: const Color.fromARGB(255, 74, 98, 138)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoomName(int index) {
    switch (index) {
      case 0:
        return 'Calming Music Room';
      case 1:
        return 'Zen Drawing Room';
      case 2:
        return 'Forest Scene Room';
      case 3:
        return 'Bubble Tapping Room';
      case 4:
        return 'Night Sky Room';
      case 5:
        return 'Ocean Waves Room';
      default:
        return '';
    }
  }

  String _getRoomDescription(int index) {
    switch (index) {
      case 0:
        return 'A soothing room with calming music and visuals.\nIdeal for anyone needing a quick mental break.';
      case 1:
        return 'A peaceful zen drawing room.\nPerfect for relaxation and mindfulness through art.';
      case 2:
        return 'Immerse yourself in a serene forest environment.\nGreat for stress relief and connection with nature.';
      case 3:
        return 'Relax by tapping bubbles and releasing stress.\nA fun and calming activity for all ages.';
      case 4:
        return 'Stargazing with a tranquil night sky.\nIdeal for those who enjoy peaceful solitude and reflection.';
      case 5:
        return 'Soothing sounds of ocean waves crashing.\nBest for relaxing and unwinding after a long day.';
      default:
        return '';
    }
  }
}
