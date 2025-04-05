import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Room5 extends StatefulWidget {
  @override
  _Room5State createState() => _Room5State();
}

class _Room5State extends State<Room5> with TickerProviderStateMixin {
  final List<Star> stars = [];
  final List<String> affirmations = [
    'You are enough!',
    'Breathe in, breathe out...',
    'You are calm and centered.',
    'Focus on the present moment.',
    'Your mind is clear and peaceful.',
    'You are strong and capable.',
    'Take a deep breath, and let it go.',
    'You are at peace with yourself.',
    'Every breath brings calm.',
    'Let go of stress and embrace relaxation.',
    'Inhale deeply, exhale slowly.',
    'Take a slow, deep breath in... and release it gently.',
    'Focus on your breath and feel your body relax.',
    'Breathe in calm, breathe out tension.',
    'With each breath, feel more relaxed and centered.',
    'Feel the air filling your lungs and releasing tension with every exhale.',
    'Inhale peace, exhale stress.',
    'Slowly inhale for a count of four... and exhale for a count of four.',
    'Focus on your breath, let it bring you inner peace.',
    'Inhale deeply, feel your body expand with each breath.'
  ];

  late Timer _starTimer;
  late Timer _shootingStarTimer;
  late AudioPlayer _audioPlayer;
  late Timer _glowingStarTimer;

  @override
  void initState() {
    super.initState();

    // Initialize the audio player for background music
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSource(AssetSource('audio/night_sky.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Add stars periodically
    _starTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _addStar();
    });

    // Shooting stars that appear randomly
    _shootingStarTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _addShootingStar();
    });

    // Timer for glowing star every 2 seconds
    _glowingStarTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _glowStar();
    });

    // Fill the sky with many stars initially
    Future.delayed(Duration.zero, () {
      for (int i = 0; i < 200; i++) {
        _addStar();
      }
      _showInstructionsDialog();
    });
  }

  void _addStar() {
    final random = Random();
    final dx = random.nextDouble() * MediaQuery.of(context).size.width;
    final dy = random.nextDouble() * MediaQuery.of(context).size.height;
    final size = random.nextDouble() * 3 + 2;
    final star = Star(dx, dy, size);

    setState(() {
      stars.add(star);
    });

    // Remove the star after some time
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        stars.remove(star);
      });
    });
  }

  void _addShootingStar() {
    final random = Random();
    final startDx = random.nextDouble() * MediaQuery.of(context).size.width;
    final startDy = 0.0;
    final endDx = random.nextDouble() * MediaQuery.of(context).size.width;
    final endDy = MediaQuery.of(context).size.height;

    _showShootingStar(startDx, startDy, endDx, endDy);
  }

  void _showShootingStar(
      double startDx, double startDy, double endDx, double endDy) {
    final animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    final tween =
        Tween(begin: Offset(startDx, startDy), end: Offset(endDx, endDy));
    final animation = tween.animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));

    animationController.forward();

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      }
    });
  }

  void _glowStar() {
    if (stars.isEmpty) return;
    final random = Random();
    final index = random.nextInt(stars.length);
    final star = stars[index];

    setState(() {
      stars[index] = Star(
        star.dx,
        star.dy,
        star.size * 2,
        isShootingStar: false,
        isGlowing: true,
      );
    });
  }

  void _onStarTapped(String affirmation, Star star) async {
    final player = AudioPlayer();
    await player.setSource(AssetSource('audio/shine.mp3'));
    await player.play(AssetSource('audio/shine.mp3'));

    setState(() {
      stars.remove(star); // Remove tapped star
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 74, 98, 138),
          title:
              Text("Affirmation", style: TextStyle(fontFamily: 'FunnelSans', color: Colors.white)),
          content:
              Text(affirmation, style: TextStyle(fontFamily: 'FunnelSans', color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(fontFamily: 'FunnelSans', color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 74, 98, 138),
          title:
              Text("Instructions", style: TextStyle(fontFamily: 'FunnelSans', color: Colors.white)),
          content: Text(
            "Tap on the glowing diamonds to receive affirmations. Watch out for shooting stars and enjoy the peaceful night sky.",
            style: TextStyle(fontFamily: 'FunnelSans'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  Text('Got it!', style: TextStyle(fontFamily: 'FunnelSans', color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _starTimer.cancel();
    _shootingStarTimer.cancel();
    _glowingStarTimer.cancel();
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Night Sky Room', style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white
          )),
        backgroundColor:
            const Color.fromARGB(255, 74, 98, 138), // Updated AppBar color
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Keep the background with clouds and stars
          Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/save_image.jpeg'), // Add your image path here
              fit: BoxFit.cover,
            ),
          ),
        ),
          // Adding a moon with a realistic look
          Positioned(
            top: 100,
            left: 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.3)
                  ],
                  center: Alignment.center,
                  radius: 0.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Adding clouds
          Positioned(
            top: 150,
            left: 100,
            child: Icon(
              Icons.cloud,
              color: Colors.white.withOpacity(0.5),
              size: 60,
            ),
          ),
          // Keep the stars and handling their taps
          ...stars
              .map((star) => Positioned(
                    left: star.dx,
                    top: star.dy,
                    child: GestureDetector(
                      onTap: () {
                        if (star.isGlowing) {
                          _onStarTapped(
                              affirmations[
                                  Random().nextInt(affirmations.length)],
                              star);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        width: star.size,
                        height: star.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle, // Diamond shape
                          color: star.isGlowing
                              ? Colors.yellow
                              : (star.isShootingStar
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.8)),
                          borderRadius:
                              BorderRadius.circular(30), // Diamond shape
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 5,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

Widget _buildBackground() {
  return Stack(
    children: [
      // Background color (black sky)
      Container(color: Colors.black),
      // Adding a moon with a realistic look
      Positioned(
        top: 100,
        left: 50,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.3)
              ],
              center: Alignment.center,
              radius: 0.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ),
      // Adding clouds
      Positioned(
        top: 150,
        left: 100,
        child: Icon(
          Icons.cloud,
          color: Colors.white.withOpacity(0.5),
          size: 60,
        ),
      ),
    ],
  );
}

class StarPainter extends CustomPainter {
  final List<Star> stars;

  StarPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;

    for (var star in stars) {
      canvas.drawCircle(Offset(star.dx, star.dy), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Star {
  final double dx;
  final double dy;
  final double size;
  final bool isShootingStar;
  final bool isGlowing;

  Star(this.dx, this.dy, this.size,
      {this.isShootingStar = false, this.isGlowing = false});
}
