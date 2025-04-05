import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:typed_data';
import 'new_room.dart';

class CreateNewRoomPage extends StatefulWidget {
  const CreateNewRoomPage({Key? key}) : super(key: key);

  @override
  _CreateNewRoomPageState createState() => _CreateNewRoomPageState();
}

class _CreateNewRoomPageState extends State<CreateNewRoomPage> {
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isLoading = false; // Add this variable to track loading state

  @override
  void initState() {
    super.initState(); // Initialize Firebase when the page loads
  }

  Future<String?> _generateStoryResponse() async {
    // Retrieve user inputs
    String mood = _moodController.text;
    String situation = _situationController.text;
    String duration = _durationController.text;

    // Create a prompt for story generation based on user inputs
    String prompt =
        'Generate a relaxing story to help someone who is feeling $mood. '
        'They are going through $situation, and they want to relax for $duration minutes. '
        'Provide a calming, uplifting story that helps them feel better and relaxed.';

    try {
      final model = FirebaseVertexAI.instance
          .generativeModel(model: 'gemini-2.0-flash-exp');
      final chat = model.startChat();

      final response = await chat.sendMessageStream(Content.text(prompt));

      String story = '';
      await for (final chunk in response) {
        if (chunk.text != null) {
          story += chunk.text!;
        }
      }

      story = story
          .replaceAll('###', '')
          .replaceAll('**', '')
          .replaceAll('##', '')
          .replaceAll('*', '•');
      return story;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error generating the story. Please try again.')),
      );
      return null;
    }
  }

  Future<List<Uint8List>?> generateImage() async {
    String mood = _moodController.text;
    String situation = _situationController.text;
    String duration = _durationController.text;
    String jsonString = await rootBundle.loadString('assets/key.json');
    final credentials =
        auth.ServiceAccountCredentials.fromJson(jsonDecode(jsonString));

    final client = await auth.clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/cloud-platform']);

    final apiUrl =
        'https://us-central1-aiplatform.googleapis.com/v1/projects/ovacare/locations/us-central1/publishers/google/models/imagen-3.0-fast-generate-001:predict';

    try {
      String prompt =
          'Generate an image of a relaxing scene for someone feeling $mood, '
          'who is going through $situation, and wants to relax for $duration minutes.';

      final response = await client.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instances': [
            {
              'prompt': prompt,
            }
          ],
          'parameters': {
            'sampleCount': 4,
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('predictions')) {
          List<Uint8List> images = [];
          for (var prediction in responseData['predictions']) {
            final imageUrl = prediction['bytesBase64Encoded'];
            Uint8List imageBytes = base64Decode(imageUrl);
            images.add(imageBytes);
          }
          return images;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No image URL returned from the API.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error generating image: ${response.statusCode} - ${response.body}')),
        );
        print(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
      );
    } finally {
      client.close();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Room',
          style: TextStyle(
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Image.asset('assets/images/relaxation_room_logo.png',
                        height: 120)),
                const SizedBox(height: 20),
                const Text(
                  'Describe your mood and needs to create a personalized relaxation room.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'FunnelSans',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'How do you feel right now?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                    fontWeight: FontWeight.w600, // Slightly bold for emphasis
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _moodController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    hintText: 'E.g. Stressed, Anxious, Relaxed',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'What are you going through?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                    fontWeight: FontWeight.w600, // Slightly bold for emphasis
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _situationController,
                  maxLines: 3, // Allows multiline input
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'E.g. Exam stress, Work pressure, Need motivation',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'How long do you want to relax?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                    fontWeight: FontWeight.w600, // Slightly bold for emphasis
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  keyboardType:
                      TextInputType.number, // Ensures only numerical input
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter time in minutes',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      String mood = _moodController.text.trim();
                      String situation = _situationController.text.trim();
                      String duration = _durationController.text.trim();

                      if (mood.isEmpty ||
                          situation.isEmpty ||
                          duration.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                            'Please fill out all fields',
                            style: TextStyle(fontFamily: 'FunnelSans'),
                          )),
                        );
                      } else {
                        setState(() {
                          _isLoading = true; // Show loading indicator
                        });

                        String? story = await _generateStoryResponse();
                        if (story == null) {
                          setState(() {
                            _isLoading = false; // Hide loading indicator
                          });
                          return;
                        }

                        List<Uint8List>? imageUrl = await generateImage();
                        if (imageUrl == null) {
                          setState(() {
                            _isLoading = false; // Hide loading indicator
                          });
                          return;
                        }

                        setState(() {
                          _isLoading = false; // Hide loading indicator
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewRoomPage(
                              story: story,
                              images: imageUrl,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Create Room',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'FunnelSans',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
