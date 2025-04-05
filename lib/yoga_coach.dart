import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:typed_data';
import 'new_yoga.dart';

class YogaCoachPage extends StatefulWidget {
  const YogaCoachPage({Key? key}) : super(key: key);

  @override
  _YogaCoachPageState createState() => _YogaCoachPageState();
}

class _YogaCoachPageState extends State<YogaCoachPage> {
 

  @override
  void initState() {
    super.initState(); // Initialize Firebase when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yoga Coach',
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

                // Mood Input
                _buildInputField(
                    label: 'How do you feel right now?',
                    hintText: 'E.g. Stressed, Anxious, Relaxed',
                    controller: _moodController),

                // Health Concern Input
                _buildInputField(
                    label: 'Any health concerns?',
                    hintText: 'E.g. PCOS, Back pain, Neck stiffness',
                    controller: _healthController),

                // Experience Level Dropdown
                _buildDropdown(
                    label: 'What is your experience level?',
                    value: _selectedExperience,
                    items: experienceLevels,
                    onChanged: (value) {
                      setState(() {
                        _selectedExperience = value!;
                      });
                    }),

                // Focus Area Dropdown
                _buildDropdown(
                    label: 'What do you want to focus on?',
                    value: _selectedFocus,
                    items: focusAreas,
                    onChanged: (value) {
                      setState(() {
                        _selectedFocus = value!;
                      });
                    }),

                // Duration Input
                _buildInputField(
                    label: 'How long do you want to practice?',
                    hintText: 'Enter time in minutes',
                    controller: _durationController,
                    isNumeric: true),

                const SizedBox(height: 30),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Suggest Yoga',
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

// Helper widget for input fields
  Widget _buildInputField(
      {required String label,
      required String hintText,
      required TextEditingController controller,
      bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.black, fontFamily: 'FunnelSans'),
          decoration: InputDecoration(
            hintText: hintText,
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
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

// Helper widget for dropdowns
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select a Language',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,

            // Default border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 74, 98, 138),
                width: 2,
              ),
            ),

            // Enabled border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 74, 98, 138),
                width: 2,
              ),
            ),

            // Focused border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 74, 98, 138),
                width: 3,
              ),
            ),

            // Error border
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),

            // Focused error border
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
        ),
        const SizedBox(height: 20),
      ],
    );
  }

// Handle submit logic
  void _handleSubmit() async {
    String mood = _moodController.text.trim();
    String health = _healthController.text.trim();
    String duration = _durationController.text.trim();
    String experience = _selectedExperience;
    String focus = _selectedFocus;

    if (mood.isEmpty ||
        health.isEmpty ||
        duration.isEmpty ||
        experience.isEmpty ||
        focus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill out all fields',
            style: TextStyle(fontFamily: 'FunnelSans'),
          ),
        ),
      );
      return;
    }

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
        builder: (context) => NewYogaPage(
          story: story,
          images: imageUrl,
        ),
      ),
    );
  }
}
