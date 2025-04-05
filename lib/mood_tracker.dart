import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  

  String _getAverageMoodText(double averageMood) {
    if (averageMood >= 4) {
      return 'Happy';
    } else if (averageMood >= 3) {
      return 'Neutral';
    } else if (averageMood >= 2) {
      return 'Stressed';
    } else {
      return 'Sad';
    }
  }

  Widget _buildMoodTile(String mood, int count) {
    Color moodColor;

    switch (mood) {
      case 'Happy':
        moodColor = Colors.green[200]!;
        break;
      case 'Sad':
        moodColor = Colors.yellow[200]!;
        break;
      case 'Stressed':
        moodColor = Colors.orange[200]!;
        break;
      case 'Angry':
        moodColor = Colors.red[200]!;
        break;
      case 'Neutral':
        moodColor = Colors.blue[200]!;
        break;
      default:
        moodColor = Colors.grey[200]!;
    }

    return Column(
      children: [
        Container(
          color: moodColor,
          padding: const EdgeInsets.all(10),
          child: Text(
            "$mood: $count",
            style: const TextStyle(
                fontSize: 16, color: Colors.black, fontFamily: 'FunnelSans'),
          ),
        ),
      ],
    );
  }

  Future<void> _addMoodData(String mood, String comment) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(userId).collection('moods').add({
        'mood': mood,
        'date': Timestamp.now(),
        'comment': comment,
      });
      _fetchMoodData();
    } catch (e) {
      print("Error adding mood data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showMoodTrackingQuestions() async {
    String mood = '';
    String comment = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "How are you feeling today?",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF4A4A4A),
                fontFamily: 'FunnelSans'),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select your mood:",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4A4A),
                        fontFamily: 'FunnelSans'),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color.fromARGB(255, 74, 98, 138), // Border color
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: mood.isNotEmpty ? mood : null,
                      hint: const Text(
                        "Select Mood",
                        style: TextStyle(
                            color: Color.fromARGB(
                                255, 74, 98, 138), // Hint text color
                            fontFamily: 'FunnelSans'),
                      ),
                      onChanged: (value) {
                        setState(() {
                          mood = value!;
                        });
                      },
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 74, 98, 138), // Text color
                          fontFamily: 'FunnelSans'),
                      items: [
                        '😊 Happy',
                        '😞 Sad',
                        '😰 Stressed',
                        '😐 Neutral',
                        '😡 Angry'
                      ]
                          .map((e) => DropdownMenuItem(
                                value: e.split(' ')[1],
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(
                                        255, 74, 98, 138), // Text color
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Any comments or thoughts?",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4A4A),
                        fontFamily: 'FunnelSans'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      comment = value;
                    },
                    decoration: const InputDecoration(
                      hintText: "Describe your mood...",
                      hintStyle: TextStyle(
                          color: Color.fromARGB(
                              255, 74, 98, 138), // Hint text color
                          fontFamily: 'FunnelSans'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color:
                              Color.fromARGB(255, 74, 98, 138), // Border color
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 74, 98, 138), // Border color when enabled
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 74, 98, 138), // Border color when focused
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 74, 98, 138), // Text color
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF9E9E9E),
                foregroundColor: Colors.white,
              ),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (mood.isNotEmpty) {
                  _addMoodData(mood, comment);
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  String _getImprovementTip(String mood) {
    switch (mood) {
      case 'Sad':
        return "Try doing something you enjoy or reach out to a friend!";
      case 'Stressed':
        return "Take a few minutes to relax and breathe deeply.";
      case 'Angry':
        return "Try taking a walk or journaling your feelings.";
      case 'Neutral':
        return "Keep a positive mindset, and do something that brings you joy!";
      case 'Happy':
        return "Keep up the positivity! Try to share it with others.";
      default:
        return "Take a moment to reflect and express gratitude.";
    }
  }

  List<Map<String, dynamic>> _filterMoodDataForDate(DateTime date) {
    return moodData?.where((entry) {
          final entryDate = (entry['date'] as Timestamp).toDate();
          return DateFormat('yyyy-MM-dd').format(entryDate) ==
              DateFormat('yyyy-MM-dd').format(date);
        }).toList() ??
        [];
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  bool _isMoodEntryAllowed(DateTime selectedDate) {
    final currentDate = DateTime.now();
    return isSameDay(selectedDate, currentDate);
  }

  Color _getBackgroundColorForMood(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.green[200]!;
      case 'Sad':
        return Colors.yellow[200]!;
      case 'Stressed':
        return Colors.orange[200]!;
      case 'Angry':
        return Colors.red[200]!;
      case 'Neutral':
        return Colors.blue[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Tracker',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TableCalendar(
                    focusedDay: _selectedDate,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                      });
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(day, _selectedDate);
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 111, 146, 206),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 74, 98, 138),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 74, 98, 138),
                      ),
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      headerMargin: const EdgeInsets.only(bottom: 8),
                      headerPadding: const EdgeInsets.only(bottom: 8),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final moodEntry = _filterMoodDataForDate(day).isNotEmpty
                            ? _filterMoodDataForDate(day).first
                            : null;
                        Color backgroundColor = moodEntry != null
                            ? _getBackgroundColorForMood(moodEntry['mood'])
                            : Color.fromARGB(255, 209, 213, 222);

                        return Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: day == _selectedDate
                                ? const Color.fromARGB(255, 74, 98, 138)
                                : backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: day == _selectedDate
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  moodData == null || moodData!.isEmpty
                      ? const Text(
                          'No Data Yet! Start tracking your mood.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 18, fontFamily: 'FunnelSans', color: const Color.fromARGB(255, 74, 98, 138)),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._filterMoodDataForDate(_selectedDate)
                                    .map((entry) {
                                  final mood = entry['mood'];
                                  final timestamp =
                                      (entry['date'] as Timestamp).toDate();
                                  final time =
                                      DateFormat('HH:mm').format(timestamp);
                                  final comment = entry['comment'] ?? '';

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getBackgroundColorForMood(mood),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.white,
                                          child: Text(
                                            _getMoodEmoji(mood),
                                            style:
                                                const TextStyle(fontSize: 28),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$time - $mood',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontFamily: 'FunnelSans'),
                                              ),
                                              if (comment.isNotEmpty)
                                                Text(
                                                  comment,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'FunnelSans'),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                  if (isSameDay(_selectedDate, DateTime.now())) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showMoodTrackingQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                      ),
                      child: const Text(
                        'Add Mood For Today',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'FunnelSans'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAnalyticsDialog,
        child: const Icon(Icons.analytics, color: Colors.white,),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Sad':
        return '😞';
      case 'Stressed':
        return '😰';
      case 'Neutral':
        return '😐';
      case 'Angry':
        return '😡';
      default:
        return '🤔';
    }
  }
}
