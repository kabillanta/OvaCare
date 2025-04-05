import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Room6 extends StatefulWidget {
  @override
  _Room6State createState() => _Room6State();
}

class _Room6State extends State<Room6> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  late Timer _messageTimer;
  int _messageIndex = 0;

  final List<String> _messages = [
    "Breathe in... and breathe out slowly.",
    "You are calm, you are at peace.",
    "Take a deep breath and relax your body.",
    "Let go of any tension with each exhale.",
    "You are in control, breathe deeply.",
    "Feel the calmness surround you, breathe steadily.",
    "Inhale deeply, and feel the energy within.",
    "Exhale slowly, releasing any stress.",
    "With every breath, feel your body becoming lighter.",
    "Imagine a peaceful place with each breath.",
    "Let the rhythm of your breath guide you.",
    "You are present in this moment, relax.",
    "Feel the weight of the world gently lifting.",
    "Breathe in positivity, breathe out negativity.",
    "Your mind is clear, your body is relaxed.",
    "Focus on the sound of your breath.",
    "Feel the calmness spread through your entire body.",
    "Let each exhale bring you more peace.",
    "Feel the gentle rise and fall of your breath.",
    "With each breath, let go of tension.",
    "You are calm, you are at ease.",
    "Focus on the sensations of the breath moving in and out.",
    "Every breath takes you deeper into relaxation.",
    "Feel your muscles soften with each breath.",
    "Release any worries, and focus on the present.",
    "Breathe in serenity, breathe out stress.",
    "You are completely safe and at peace.",
    "Let go of all thoughts, and simply breathe.",
    "You are grounded and centered with every inhale.",
    "Take a deep breath, and smile with your heart.",
    "Every breath fills you with calm and tranquility.",
    "You are free from stress with each exhale."
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _audioPlayer = AudioPlayer();
    _startBackgroundMusic();
    _startMessageTimer();
  }

  // Function to start background music
  void _startBackgroundMusic() async {
    await _audioPlayer.setSourceAsset('audio/night_sky.mp3');
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Ensure it loops forever
    _audioPlayer.play(AssetSource('audio/night_sky.mp3'));
  }

  // Function to start a timer that displays messages every 5 seconds
  void _startMessageTimer() {
    _messageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageTimer.cancel();
    _audioPlayer.stop(); // Stop the audio when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ocean Waves Room',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        backgroundColor:
            const Color.fromARGB(255, 74, 98, 138), // New app bar color
      ),
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ocean wave animation using CustomPainter
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: OceanPainter(
                    progress: _controller.value,
                  ),
                );
              },
            ),
            // Breathing instructions and affirmations
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _messages[_messageIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OceanPainter extends CustomPainter {
  final double progress;

  OceanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue.withOpacity(0.6);
    double waveHeight = 30.0; // Reduced wave height
    double waveFrequency = 10.0; // Reduced frequency for less crowded waves

    Path path = Path();
    path.moveTo(0, size.height / 2);

    // Create ocean wave animation
    for (double x = 0; x <= size.width; x++) {
      double y = (waveHeight *
              sin((progress * waveFrequency + x / waveFrequency) * pi)) +
          size.height / 2;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw fish swimming
    _drawFish(canvas, size);

    // Draw bubbles rising
    _drawBubbles(canvas, size);
  }

  // Function to draw moving fish
  void _drawFish(Canvas canvas, Size size) {
    Paint fishPaint = Paint()..color = Colors.orange;
    double fishSize = 20.0;
    double fishSpeed = 0.1 + sin(progress * pi) * 0.5;

    // Create fish position based on animation progress
    for (double i = 0; i <= size.width; i += 100) {
      double fishX = (i + progress * 100) % size.width;
      double fishY = size.height / 2 + sin(fishX * 0.1) * 50;
      canvas.drawCircle(Offset(fishX, fishY), fishSize, fishPaint);
    }
  }

  // Function to draw bubbles rising
  void _drawBubbles(Canvas canvas, Size size) {
    Paint bubblePaint = Paint()..color = Colors.white.withOpacity(0.6);
    double bubbleSize = 5.0;

    // Create bubble rise effect
    for (double i = 0; i <= size.width; i += 50) {
      double bubbleX = (i + progress * 100) % size.width;
      double bubbleY =
          size.height / 2 + sin(bubbleX * 0.2) * 20 - progress * 150;
      if (bubbleY < 0)
        bubbleY = size.height; // Reset bubble to bottom when it reaches top
      canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleSize, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
