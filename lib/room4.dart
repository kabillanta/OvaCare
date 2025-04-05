import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Room3 extends StatefulWidget {
  @override
  _Room3State createState() => _Room3State();
}

class _Room3State extends State<Room3> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  late Timer _breathingTimer;
  int _currentStep = 0;
  
  // 20-step breathing routine
  final List<String> _breathingInstructions = [
    'Breathe in deeply...',
    'Hold for a moment...',
    'Breathe out slowly...',
    'Breathe in deeply...',
    'Hold for a moment...',
    'Breathe out slowly...',
    'Breathe in deeply...',
    'Hold for a moment...',
    'Breathe out slowly...',
    'Breathe in deeply...',
    'Hold for a moment...',
    'Breathe out slowly...',
    'Breathe in deeply...',
    'Hold for a moment...',
    'Breathe out slowly...',
    'Breathe in deeply...',
    'Hold for a moment...',
    'Breathe out slowly...',
    'Breathe in deeply...',
    'Hold for a moment...',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the video controller
    _videoController = VideoPlayerController.asset('assets/video/forest_scene.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoController.play(); // Play video after initialization
        });
      }).catchError((e) {
        print('Error initializing video: $e'); // Catch errors during initialization
      });

    // Set up the zoom animation
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
      reverseDuration: const Duration(seconds: 15),
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeInOut,
      ),
    );

    _zoomController.repeat(reverse: true); // To zoom in and out continuously

    // Start the breathing timer to show instructions every 5 seconds
    _breathingTimer = Timer.periodic(Duration(seconds: 5), _updateBreathingInstruction);
  }

  void _updateBreathingInstruction(Timer timer) {
    setState(() {
      _currentStep = (_currentStep + 1) % _breathingInstructions.length;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _zoomController.dispose();
    _breathingTimer.cancel();  // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forest Scene',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video background with zooming effect
            AnimatedBuilder(
              animation: _zoomAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  child: VideoPlayer(_videoController),
                );
              },
            ),
            // Breathing instructions
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  _breathingInstructions[_currentStep],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    backgroundColor: Colors.black.withOpacity(0.5),
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
