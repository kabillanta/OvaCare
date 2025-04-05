import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class CycleTrackerPage extends StatefulWidget {
  const CycleTrackerPage({Key? key}) : super(key: key);

  @override
  _CycleTrackerPageState createState() => _CycleTrackerPageState();
}

class _CycleTrackerPageState extends State<CycleTrackerPage> {
  DateTime? _lastPeriodStart;
  int _avgCycleLength = 28;
  bool _isLogging = false;
  String _flowIntensity = "Moderate";
  int _padsUsed = 0;
  bool _spotting = false;
  String _insights = "";
  DateTime? _predictedNextPeriod;
  Map<DateTime, Map<String, dynamic>> _periodData = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    fetchCycleData();
  }

  Future<void> fetchCycleData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final cycleHistory = snapshot.data()?['cycleHistory'] as List<dynamic>? ?? [];

      if (cycleHistory.isNotEmpty) {
        final lastCycleDate = (cycleHistory.last['date'] as Timestamp?)?.toDate();
        _lastPeriodStart = lastCycleDate;
        _avgCycleLength = _calculateAvgCycleLength(cycleHistory);
      }

      // Convert past period data for color coding the calendar
      for (var entry in cycleHistory) {
        final date = (entry['date'] as Timestamp).toDate();
        _periodData[date] = {
          'flowIntensity': entry['flowIntensity'],
          'padsUsed': entry['padsUsed'],
          'spotting': entry['spotting'],
        };
      }

      // Predict the next period on loading
      await predictNextCycle();

      setState(() {});
    }
  }

  int _calculateAvgCycleLength(List<dynamic> history) {
    if (history.length < 2) return 28;

    List<int> cycleLengths = [];
    for (int i = 1; i < history.length; i++) {
      final prevDate = (history[i - 1]['date'] as Timestamp).toDate();
      final currDate = (history[i]['date'] as Timestamp).toDate();
      cycleLengths.add(currDate.difference(prevDate).inDays);
    }
    return (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();
  }

  Future<void> logCycleData() async {
    final user = _auth.currentUser;
    if (user == null || _lastPeriodStart == null) return;

    setState(() => _isLogging = true);

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    List<dynamic> cycleHistory = snapshot.data()?['cycleHistory'] ?? [];

    cycleHistory.add({
      'date': Timestamp.fromDate(_lastPeriodStart!),
      'flowIntensity': _flowIntensity,
      'padsUsed': _padsUsed,
      'spotting': _spotting,
    });

    await userRef.set({
      'cycleHistory': cycleHistory,
    }, SetOptions(merge: true));

    await predictNextCycle();

    setState(() => _isLogging = false);
  }

  Future<void> predictNextCycle() async {
    if (_lastPeriodStart == null) return;

    setState(() => _insights = "Predicting next cycle...");

    // Initialize the generative model
    final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
    final chat = model.startChat();

    // Prepare the prompt for the model
    final prompt = Content.text(
      "Based on the user's menstrual cycle history:\n"
      "- Last period started on: ${_lastPeriodStart!.toIso8601String()}\n"
      "- Average cycle length: $_avgCycleLength days\n"
      "- Flow intensity: $_flowIntensity\n"
      "- Pads used: $_padsUsed\n"
      "- Spotting: $_spotting\n"
      "Predict the next period start date and provide insights into:\n"
      "1. Expected cycle regularity\n"
      "2. Potential variations in cycle length\n"
      "3. Recommendations for managing irregular cycles\n"
      "4. Any concerns based on logged flow and symptoms."
    );

    // Send the prompt to the model
    final response = await chat.sendMessageStream(prompt);

    // Process the response
    String generatedText = "";
    await for (final chunk in response) {
      if (chunk.text != null) {
        generatedText += chunk.text!;
      }
    }

    // Extract relevant details using regex
    final predictedCycleLengthMatch = RegExp(r'Predicted cycle length: (\d+) days').firstMatch(generatedText);
    final insightsMatch = RegExp(r'Insights:\s*(.*)').firstMatch(generatedText);

    // Update state with extracted details
    setState(() {
      if (predictedCycleLengthMatch != null) {
        _avgCycleLength = int.tryParse(predictedCycleLengthMatch.group(1) ?? "$_avgCycleLength") ?? _avgCycleLength;
      }
      _predictedNextPeriod = _lastPeriodStart!.add(Duration(days: _avgCycleLength));
      _insights = insightsMatch?.group(1) ?? "No insights available.";
    });
  }

  DateTime? getNextPeriodPrediction() {
    if (_lastPeriodStart == null) return null;
    return _lastPeriodStart!.add(Duration(days: _avgCycleLength));
  }

  Color _getColorForDate(DateTime date) {
    if (!_periodData.containsKey(date)) return Colors.transparent;
    String flow = _periodData[date]!['flowIntensity'];
    if (flow == "Heavy") return Colors.redAccent;
    if (flow == "Moderate") return Colors.orange;
    if (flow == "Light") return Colors.yellow;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final nextPeriod = getNextPeriodPrediction();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cycle Tracker',
          style: TextStyle(fontFamily: 'FunnelSans', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A628A),
      ),
      backgroundColor: const Color(0xFFF1F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Track Your Menstrual Cycle",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'FunnelSans', color: Colors.black),
            ),
            const SizedBox(height: 12),

            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _lastPeriodStart ?? DateTime.now(),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              selectedDayPredicate: (day) {
                return _lastPeriodStart != null && isSameDay(day, _lastPeriodStart);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _lastPeriodStart = selectedDay;
                });
                logCycleData();
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getColorForDate(day),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_predictedNextPeriod != null)
              Text(
                "Predicted Next Period: ${DateFormat.yMMMMd().format(_predictedNextPeriod!)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Flow Intensity:", style: TextStyle(fontSize: 16, color: Colors.black)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _flowIntensity,
                  items: ["Light", "Moderate", "Heavy"].map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _flowIntensity = value);
                      logCycleData();
                    }
                  },
                ),
              ],
            ),

            Row(
              children: [
                const Text("Pads Used:", style: TextStyle(fontSize: 16, color: Colors.black)),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _padsUsed,
                  items: List.generate(10, (index) => index).map((int count) {
                    return DropdownMenuItem<int>(
                      value: count,
                      child: Text("$count"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _padsUsed = value);
                      logCycleData();
                    }
                  },
                ),
              ],
            ),

            SwitchListTile(
              title: const Text("Spotting"),
              value: _spotting,
              onChanged: (value) {
                setState(() => _spotting = value);
                logCycleData();
              },
            ),

            _isLogging ? const CircularProgressIndicator() : const SizedBox.shrink(),

            if (_insights.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _insights,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}