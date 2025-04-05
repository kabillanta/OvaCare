import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Room1 extends StatefulWidget {
  @override
  _Room1State createState() => _Room1State();
}

class _Room1State extends State<Room1> {
  late AudioPlayer _audioPlayer;
  int currentStep = 0;

  final List<String> _meditationSteps = [
  "Step 1: Find a comfortable spot and sit down, as if you're settling under a gentle rainstorm.",
  "Step 2: Take a deep breath in through your nose, like you're inhaling the fresh air before the rain begins.",
  "Step 3: Exhale slowly through your mouth, releasing any tension, just as raindrops fall effortlessly.",
  "Step 4: Focus on your breath, like the steady rhythm of raindrops tapping gently on your window.",
  "Step 5: Let go of any tension in your body, letting it flow away, just like rain washing away stress.",
  "Step 6: Imagine yourself surrounded by the calming sound of rain, creating a serene atmosphere.",
  "Step 7: Visualize the raindrops falling around you, each drop creating a peaceful rhythm.",
  "Step 8: Focus on the sounds of nature, as if each raindrop is reminding you to stay present in the moment.",
  "Step 9: Feel the peace of your surroundings, as still and soothing as the world during a gentle rainstorm.",
  "Step 10: Inhale positivity, like the fresh scent of earth after the rain.",
  "Step 11: Exhale any stress, letting it dissolve into the earth, just as raindrops soak into the soil.",
  "Step 12: Pay attention to your heartbeat, steady and calming, like the rhythm of rainfall.",
  "Step 13: Feel the natural flow of your body, like the stream of rainwater moving gently around you.",
  "Step 14: Let go of your thoughts, allowing them to drift away, like raindrops floating on a calm surface.",
  "Step 15: Allow your body to relax deeper, like the peace that follows a soft, gentle rainfall.",
  "Step 16: Visualize a gentle light surrounding you, like the soft glow after the rain has passed.",
  "Step 17: Embrace the peacefulness around you, like the serenity that lingers after a storm.",
  "Step 18: Focus on gratitude, appreciating the calm and clarity brought by the rain.",
  "Step 19: Slowly bring your awareness to the present, feeling refreshed, like the world after a cleansing rain."
];


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSource(AssetSource('audio/meditation_music.mp3')); // Add your sound asset
    _audioPlayer.play(AssetSource('audio/meditation_music.mp3'));

    // Timer to cycle through meditation steps
    Future.delayed(Duration(seconds: 5), _startMeditationSteps);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startMeditationSteps() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        if (currentStep < _meditationSteps.length - 1) {
          currentStep++;
          _startMeditationSteps();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rain Drops Scene',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      body: GestureDetector(
        onTap: () {}, // Tap to toggle any action if needed
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background color to create a calm ambiance
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.withOpacity(0.5), Colors.white],
                ),
              ),
            ),
            // Simple Raindrop Effect - Positioned drops with an animation
            for (var i = 0; i < 20; i++) _RainDrop(i),
            // Meditation step instructions overlay
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15, // Gradual placement from top
              left: 20,
              right: 20,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      _meditationSteps[currentStep],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        backgroundColor: Colors.black.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RainDrop extends StatefulWidget {
  final int index;
  _RainDrop(this.index);

  @override
  _RainDropState createState() => _RainDropState();
}

class _RainDropState extends State<_RainDrop> with TickerProviderStateMixin {
  late AnimationController _controller;
  late double _dropSpeed; // To store the random speed

  @override
  void initState() {
    super.initState();

    // Generate random speed for each raindrop (between 1.5 to 4 seconds)
    _dropSpeed = Random().nextDouble() * 2.5 + 1.5;

    // Set up the animation controller with the random speed
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _dropSpeed.toInt()), // Randomize fall speed
    )..repeat(); // Make it repeat forever
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Randomize horizontal starting position
    final randomHorizontalPosition =
        Random().nextDouble() * MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: randomHorizontalPosition,
          top: _controller.value * MediaQuery.of(context).size.height,
          child: Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 26, 84, 185).withOpacity(0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }
}
