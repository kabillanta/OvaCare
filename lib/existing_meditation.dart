import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repeat_meditation.dart';

class ExistingMeditationPage extends StatefulWidget {

  const ExistingMeditationPage({Key? key}) : super(key: key);

  @override
  _ExistingMeditationPageState createState() => _ExistingMeditationPageState();
}

class _ExistingMeditationPageState extends State<ExistingMeditationPage> {
  bool _isLoading = false;
  List<DocumentSnapshot> _meditations = [];
  late String userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
    _fetchSavedMeditations();
  }

  Future<void> _fetchSavedMeditations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final meditationsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meditations')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _meditations = meditationsQuery.docs;
      });
    } catch (e) {
      print("Error fetching saved meditations: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Meditations',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : _meditations.isEmpty
                  ? const Text(
                      'No saved meditations. Start saving to use in future.',
                      style: TextStyle(fontSize: 18, color: Colors.black,fontFamily: 'FunnelSans' ),
                    )
                  : ListView.builder(
                      itemCount: _meditations.length,
                      itemBuilder: (context, index) {
                        final meditation = _meditations[index];
                        final title = meditation['title'] ?? 'No Title';
                        final language = meditation['language'] ?? 'Unknown Language';
                        final timestamp = (meditation['timestamp'] as Timestamp).toDate();
                        final dateFormatted = DateFormat('yyyy-MM-dd').format(timestamp);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RepeatMeditationPage(
                                  story: meditation['story'],
                                  language: meditation['language'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 74, 98, 138),
                                  fontFamily: 'FunnelSans'
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language, style: const TextStyle(color: Colors.black)),
                                  Text(dateFormatted, style: const TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}