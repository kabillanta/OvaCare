import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Room4 extends StatefulWidget {
  @override
  _Room4State createState() => _Room4State();
}

class _Room4State extends State<Room4> with TickerProviderStateMixin { // Add the mixin here
  final List<Bubble> bubbles = [];
  final List<Color> bubbleColors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
  final List<String> instructions = [
    'Burst a Red Bubble!',
    'Burst a Blue Bubble!',
    'Burst a Green Bubble!',
    'Burst a Yellow Bubble!',
    'Burst a Purple Bubble!',
  ];

  late Timer _bubbleTimer;
  late Timer _instructionTimer;
  String currentInstruction = "Tap the bubbles!";
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Spawn bubbles every second
    _bubbleTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _addBubble();
    });

    // Update instruction every 5 seconds
    _instructionTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _updateInstruction();
    });
  }

  void _addBubble() {
  final random = Random();
  
  // You can increase this number to spawn more bubbles at once
  int numberOfBubblesToAdd = 5; // Number of bubbles to spawn at once
  
  for (int i = 0; i < numberOfBubblesToAdd; i++) {
    final color = bubbleColors[random.nextInt(bubbleColors.length)];
    final dx = random.nextDouble() * (MediaQuery.of(context).size.width - 60);
    final dy = random.nextDouble() * (MediaQuery.of(context).size.height - 150);
    final dxSpeed = random.nextDouble() * 2 - 1; // Random horizontal speed
    final dySpeed = random.nextDouble() * 2 - 1; // Random vertical speed

    setState(() {
      bubbles.add(Bubble(dx, dy, color, dxSpeed, dySpeed, this));
    });

    // Remove bubbles after 6 seconds
    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        bubbles.removeWhere((bubble) => bubble.dx == dx && bubble.dy == dy);
      });
    });
  }
}


  void _updateInstruction() {
    final random = Random();
    setState(() {
      currentInstruction = instructions[random.nextInt(instructions.length)];
    });
  }

  void _popBubble(Bubble bubble) async {
    _audioPlayer.play(AssetSource('audio/pop.mp3'));

    setState(() {
      bubbles.remove(bubble);
    });
  }

  @override
  void dispose() {
    _bubbleTimer.cancel();
    _instructionTimer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubble Tapping Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'FunnelSans'),),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),

      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bubble_background.jpeg',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currentInstruction,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          for (var bubble in bubbles)
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              left: bubble.dx,
              top: bubble.dy,
              child: GestureDetector(
                onTap: () => _popBubble(bubble),
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: 1.0,
                  child: AnimatedBuilder(
                    animation: bubble.animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: bubble.animation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                bubble.color.withOpacity(0.8),
                                bubble.color.withOpacity(0.4)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: bubble.color.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Bubble {
  final double dx;
  final double dy;
  final Color color;
  final double dxSpeed;
  final double dySpeed;
  late AnimationController animation;

  Bubble(this.dx, this.dy, this.color, this.dxSpeed, this.dySpeed, TickerProvider vsync) {
    animation = AnimationController(vsync: vsync, duration: Duration(seconds: 1))..repeat();
  }

  void pop() {
    animation.stop();
    animation = AnimationController(vsync: _Room4State(), duration: Duration(seconds: 1))
      ..reverse(from: 1.0)
      ..addListener(() {
        if (animation.isDismissed) {
          // Remove the bubble after animation
        }
      });
  }
}
