import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'new_meditation.dart';

class CreateNewMeditationPage extends StatefulWidget {
  const CreateNewMeditationPage({Key? key}) : super(key: key);

  @override
  _CreateNewMeditationPageState createState() =>
      _CreateNewMeditationPageState();
}

class _CreateNewMeditationPageState extends State<CreateNewMeditationPage> {
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _focusController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedLanguage = 'English'; // Default language
  bool _isLoading = false; // To track loading state

  // Map of languages with their codes
  final Map<String, String> _languages = {
    'English': 'en',
    'Tamil': 'ta',
    'Hindi': 'hi',
    'Kannada': 'kn',
    'Malayalam': 'ml',
    'Telugu': 'te',
    'Urdu': 'ur',
  };

  @override
  void initState() {
    super.initState(); // Initialize Firebase when the page loads
  }

  Future<String?> _generateMeditationScript() async {
    // Retrieve user inputs
    String mood = _moodController.text;
    String focus = _focusController.text;
    String duration = _durationController.text;

    // Create a prompt for meditation script generation
    String prompt =
        'Create a guided meditation script for someone who is feeling $mood. '
        'They want to focus on $focus and meditate for $duration minutes. '
        'The script should be calming, uplifting, and help them feel relaxed and centered. '
        'Include breathing exercises, body scan techniques, and positive affirmations.';

    try {
      final model = FirebaseVertexAI.instance
          .generativeModel(model: 'gemini-2.0-flash-exp');
      final chat = model.startChat();

      final response = await chat.sendMessageStream(Content.text(prompt));

      String script = '';
      await for (final chunk in response) {
        if (chunk.text != null) {
          script += chunk.text!;
        }
      }

      // Clean up the script
      script = script
          .replaceAll('###', '')
          .replaceAll('**', '')
          .replaceAll('##', '')
          .replaceAll('*', '•');
      return script;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Error generating the meditation script. Please try again.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Meditation',
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
                    child: Image.asset('assets/images/harmony_hub.png',
                        height: 120)),
                const SizedBox(height: 20),
                const Text(
                  'Describe your mood and focus to create a personalized meditation room.',
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
                  'How are you feeling right now?',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'FunnelSans'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _moodController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    hintText: 'E.g. Stressed, Anxious, Calm',
                    hintStyle: TextStyle(
                        color: Colors.grey), // Optional: Hint text color
                    filled: true,
                    fillColor: Colors.white, // Background color

                    // Default border (applies if no other states match)
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when the TextField is enabled but not focused
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when the TextField is focused
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3, // Slightly thicker border for focus
                      ),
                    ),

                    // Border when there's an error (e.g., validation fails)
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),

                    // Border when focused but there's an error
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
                  'What would you like to focus on during meditation?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _focusController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    hintText: 'E.g. Relaxation, Stress relief, Gratitude',
                    hintStyle: TextStyle(
                        color: Colors.grey), // Optional hint text color
                    filled: true,
                    fillColor: Colors.white, // Background color

                    // Default border
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when the TextField is enabled
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when the TextField is focused
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3, // Slightly thicker for focus
                      ),
                    ),

                    // Border when there's an error
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),

                    // Border when focused but there's an error
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
                  'How long would you like to meditate?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter time in minutes (e.g., 10, 20)',
                    hintStyle: TextStyle(
                        color: Colors.grey), // Optional hint text color
                    filled: true,
                    fillColor: Colors.white, // Background color

                    // Default border
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when the TextField is enabled
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when the TextField is focused
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3, // Slightly thicker for focus
                      ),
                    ),

                    // Border when there's an error
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),

                    // Border when focused but there's an error
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
                  'In which language would you like the script?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select a Language',
                    hintStyle: TextStyle(
                        color: Colors.grey), // Optional hint text color
                    filled: true,
                    fillColor: Colors.white, // Background color

                    // Default border
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when enabled
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 2,
                      ),
                    ),

                    // Border when focused
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138),
                        width: 3, // Slightly thicker for focus
                      ),
                    ),

                    // Border when there's an error
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),

                    // Border when focused but there's an error
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'FunnelSans',
                  ),
                  items: _languages.keys.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      String mood = _moodController.text.trim();
                      String focus = _focusController.text.trim();
                      String duration = _durationController.text.trim();
                      String language = _languages[
                          _selectedLanguage]!; // Get the language code

                      if (mood.isEmpty ||
                          focus.isEmpty ||
                          duration.isEmpty ||
                          language.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill out all fields')),
                        );
                      } else {
                        setState(() {
                          _isLoading = true; // Show loading indicator
                        });

                        String? script = await _generateMeditationScript();
                        if (script == null) {
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
                            builder: (context) => NewMeditationPage(
                                story: script,
                                language: _selectedLanguage,
                                mood: mood,
                                focus: focus),
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
                            'Create Meditation Session',
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
