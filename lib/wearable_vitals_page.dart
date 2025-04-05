import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WearableVitalsPage extends StatefulWidget {
  const WearableVitalsPage({Key? key}) : super(key: key);

  @override
  _WearableVitalsPageState createState() => _WearableVitalsPageState();
}

class _WearableVitalsPageState extends State<WearableVitalsPage> {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wearable Vitals',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current wearable data card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color.fromARGB(255, 66, 104, 170),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          "Heart Rate: ${currentData.heartRate} bpm",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'FunnelSans',
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          "Steps: ${currentData.stepCount}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'FunnelSans',
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.hotel, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "Sleep: ${currentData.sleepHours.toStringAsFixed(1)} hrs",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'FunnelSans',
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          "Temp: ${currentData.bodyTemperature.toStringAsFixed(1)}°C",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'FunnelSans',
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Insights card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: primaryColor,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Insights",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'FunnelSans',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      insights,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'FunnelSans',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Historical Data Graph Card using CustomPaint
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color.fromARGB(255, 220, 236, 236),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last 7 Days 📈",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'FunnelSans',
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 74, 98, 138)
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _LineChartPainter(
                            data: [
                              [75, 80, 78, 82, 77, 85, 90], // Heart Rate
                              [6, 7, 6.5, 5.8, 7.2, 6.9, 7.4], // Sleep (Hours)
                              [
                                5000,
                                7000,
                                8000,
                                7500,
                                8500,
                                9000,
                                9500
                              ], // Steps
                            ],
                            backgroundColor:
                                const Color.fromARGB(255, 241, 249, 249)),
                      ),
                    ),
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

// A simple custom painter for a line chart
class _LineChartPainter extends CustomPainter {
  final List<List<double>> data; // 3 Lists: Heart Rate, Sleep, Steps
  final Color backgroundColor;
  final List<Color> colors = [
    const Color.fromARGB(255, 235, 129, 129), // Heart Rate
    const Color.fromARGB(255, 76, 123, 203), // Sleep
    const Color.fromARGB(255, 114, 235, 177), // Steps
  ];

  _LineChartPainter({required this.data, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.any((list) => list.isEmpty)) return;

    // Use the screen's background color
    final Paint backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Axis Paint
    final Paint axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.0;

    // Dotted Grid Paint
    final Paint gridPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    // Dotted Effect
    final Path dashPath = Path();
    for (double i = 0; i <= size.height; i += size.height / 5) {
      dashPath.moveTo(0, i);
      dashPath.lineTo(size.width, i);
    }
    for (double i = 0;
        i <= size.width;
        i += size.width / (data[0].length - 1)) {
      dashPath.moveTo(i, 0);
      dashPath.lineTo(i, size.height);
    }
    canvas.drawPath(dashPath, gridPaint);

    // Draw axes
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // Iterate through each dataset (Heart Rate, Sleep, Steps)
    for (int index = 0; index < data.length; index++) {
      final List<double> metricData = data[index];
      final double minVal = metricData.reduce(min);
      final double maxVal = metricData.reduce(max);
      final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
      final double stepX = size.width / (metricData.length - 1);

      // Paint for line and dots
      final Paint linePaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, size.height),
          Offset(size.width, 0),
          [colors[index].withOpacity(0.8), colors[index]],
        )
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final Paint dotPaint = Paint()..color = colors[index];

      // Map data to chart points
      List<Offset> points = [];
      for (int i = 0; i < metricData.length; i++) {
        double normalized = (metricData[i] - minVal) / range;
        double y = size.height - (normalized * size.height);
        double x = i * stepX;
        points.add(Offset(x, y));
      }

      // Draw smooth path
      final Path path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        double midX = (points[i - 1].dx + points[i].dx) / 2;
        double midY = (points[i - 1].dy + points[i].dy) / 2;
        path.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, midX, midY);
      }
      canvas.drawPath(path, linePaint);

      // Draw dots
      for (var point in points) {
        canvas.drawCircle(point, 4, dotPaint);
      }
    }

    // ** Draw Legend **
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    final List<String> labels = ["Heart Rate", "Sleep", "Steps"];

    for (int i = 0; i < labels.length; i++) {
      final Paint legendPaint = Paint()..color = colors[i];
      canvas.drawCircle(
          Offset(size.width - 100, 20 + (i * 20)), 6, legendPaint);

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 90, 14 + (i * 20)));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

// A class to generate mock wearable data
class MockWearableData {
  final int heartRate;
  final int stepCount;
  final double sleepHours;
  final double bodyTemperature;

  MockWearableData({
    required this.heartRate,
    required this.stepCount,
    required this.sleepHours,
    required this.bodyTemperature,
  });

  factory MockWearableData.generate() {
    final random = Random();
    return MockWearableData(
      heartRate: 60 + random.nextInt(41), // 60 to 100 bpm
      stepCount: 3000 + random.nextInt(7001), // 3000 to 10000 steps
      sleepHours: 6 + random.nextDouble() * 3, // 6 to 9 hours
      bodyTemperature: 36.5 + random.nextDouble(), // 36.5 to 37.5°C
    );
  }

  @override
  String toString() {
    return 'Heart Rate: $heartRate bpm, Steps: $stepCount, Sleep: ${sleepHours.toStringAsFixed(1)} hrs, Temp: ${bodyTemperature.toStringAsFixed(1)}°C';
  }
}

// Generate insights based on the mock data (with a PCOS focus)
String generateInsights(MockWearableData data) {
  final StringBuffer insights = StringBuffer();

  // Heart rate insight
  if (data.heartRate > 90) {
    insights.writeln(
        "Your resting heart rate is high. Elevated heart rates can indicate stress, which may worsen PCOS symptoms. 😟");
  } else if (data.heartRate < 65) {
    insights.writeln(
        "Your heart rate is on the lower side, which might be normal if you're well-rested. Keep monitoring. 👍");
  } else {
    insights.writeln("Your heart rate is within a normal range. 🙂");
  }

  // Steps insight
  if (data.stepCount < 5000) {
    insights.writeln(
        "Your daily activity is low. Increasing your step count can help improve insulin sensitivity and regulate hormones. 🚶‍♀️");
  } else if (data.stepCount < 8000) {
    insights.writeln(
        "You're moderately active. A bit more activity could further benefit your PCOS management. 👍");
  } else {
    insights.writeln(
        "Great job staying active! Regular physical activity is beneficial for managing PCOS symptoms. 🏃‍♀️");
  }

  // Sleep insight
  if (data.sleepHours < 7) {
    insights.writeln(
        "You're not getting enough sleep. Adequate sleep is crucial for hormone regulation and stress reduction. 😴");
  } else {
    insights.writeln(
        "Your sleep duration is good, which supports overall hormonal balance. 😌");
  }

  // Body temperature insight
  if (data.bodyTemperature > 37.2) {
    insights.writeln(
        "Your body temperature is slightly elevated. Managing stress and staying hydrated can help maintain hormonal balance. 💧");
  } else {
    insights.writeln("Your body temperature is normal. 😊");
  }

  return insights.toString();
}
