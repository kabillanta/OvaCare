import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;

class Room2 extends StatefulWidget {
  @override
  _Room2State createState() => _Room2State();
}

class _Room2State extends State<Room2> {
  late AudioPlayer _audioPlayer;
  Timer? instructionTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();

    // Show initial instruction pop-up
    Future.delayed(Duration(seconds: 1), () {
      _showInstructionDialog();
    });

    // Send new instructions every 10 seconds
    instructionTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _showInstructionDialog();
    });
  }

  void _playBackgroundMusic() async {
    await _audioPlayer.setSource(AssetSource('audio/forest-river-240225.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('audio/forest-river-240225.mp3'));
  }

  void _showInstructionDialog() {
    List<String> instructions = [
      // Drawing prompts
      'Draw a Circle', 'Draw a Star', 'Draw a Wave',
      'Draw a Spiral', 'Draw a Heart', 'Draw a Flower',
      'Draw a Tree', 'Draw a Sun', 'Draw a Mountain',
      'Draw a Feather', 'Draw a Raindrop', 'Draw a Mandala',
      'Draw a Leaf', 'Draw a Cloud', 'Draw a Butterfly',
      'Draw a River', 'Draw a House', 'Draw a Bird',
      'Draw a Fish', 'Draw a Dolphin', 'Draw a Shell',
      'Draw a Shooting Star', 'Draw a Rainbow', 'Draw a Crescent Moon',
      'Draw a Lightning Bolt', 'Draw a Snowflake', 'Draw a Pebble Path',
      'Draw a Waterfall', 'Draw a Flame', 'Draw a Wind Swirl',
      'Draw a Seashell', 'Draw a Kite in the Sky', 'Draw a Jellyfish',
      'Draw a Branch with Leaves', 'Draw a Sand Dune', 'Draw a Coral Reef',

      // Breathing and mindfulness prompts
      'Take a deep breath in for 4 seconds, hold for 7 seconds, and exhale for 8 seconds.',
      'Breathe in deeply through your nose, hold for 5 seconds, and slowly release through your mouth.',
      'Imagine a calm ocean wave. Breathe in as it rises, breathe out as it falls.',
      'Close your eyes and take 3 slow, deep breaths.',
      'Breathe in through your nose like you’re smelling a flower, exhale through your mouth like you’re blowing out a candle.',
      'Slowly inhale for 6 seconds, hold for 3 seconds, exhale for 6 seconds.',
      'Take a deep breath and exhale as if you’re blowing bubbles.',
      'Visualize a balloon inflating as you breathe in, and deflating as you breathe out.',
      'Breathe in deeply, imagining your breath filling your entire body with calmness.',
      'Try box breathing: inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, hold for 4 seconds, repeat.',
      'Take a long, slow breath in, and let out a deep sigh of relief.',
      'Inhale through your nose, hold for a moment, then exhale completely through your mouth.',
      'Breathe in, count to 3, breathe out slowly while relaxing your shoulders.',
      'Take a deep breath and exhale through pursed lips like blowing through a straw.',
    ];

    String randomInstruction =
        instructions[Random().nextInt(instructions.length)];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 74, 98, 138),
          title: Text(
            "Zen Instruction",
            style: TextStyle(color: Colors.white, fontFamily: 'FunnelSans'),
          ),
          content: Text(
            randomInstruction,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 74, 98, 138)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  Text("Start Drawing", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    instructionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SandDrawingCanvas(),
      ),
    );
  }
}

class SandDrawingCanvas extends StatefulWidget {
  @override
  _SandDrawingCanvasState createState() => _SandDrawingCanvasState();
}

class _SandDrawingCanvasState extends State<SandDrawingCanvas> {
  List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _points.add(details.localPosition);
        });
      },
      onPanEnd: (details) {
        _points.add(null);
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: SandDrawingPainter(_points),
      ),
    );
  }
}

class SandDrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Random _random = Random();

  SandDrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 74, 98, 138) // Drawing color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    // Draw user strokes
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null) {
        canvas.drawCircle(points[i]!, 3.0, paint);
      }
    }

    // Add texture with grains
    final grainPaint = Paint()
      ..color = Colors.brown.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    List<Offset> grainPoints = [];
    int numGrains = 50000; // Increase this to add more grains

    for (int i = 0; i < numGrains; i++) {
      double x = _random.nextDouble() * size.width;
      double y = _random.nextDouble() * size.height;
      grainPoints.add(Offset(x, y));
    }

    // Draw grains using PointMode.points
    canvas.drawPoints(ui.PointMode.points, grainPoints, grainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
