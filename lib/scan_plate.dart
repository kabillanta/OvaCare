// ignore_for_file: all

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To pick images from gallery or camera
import 'package:firebase_vertexai/firebase_vertexai.dart'; // For using Gemini API
import 'dart:io'; // For file handling

class ScanPlate extends StatefulWidget {
  const ScanPlate({super.key});

  @override
  _ScanPlateState createState() => _ScanPlateState();
}

class _ScanPlateState extends State<ScanPlate> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _response = ''; // To hold recipe response

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // Function to trigger chat and get recipe using Gemini API
  Future<void> _getRecipeFromImage() async {
    if (_image == null) return;

    try {
      final model = FirebaseVertexAI.instance
          .generativeModel(model: 'gemini-2.0-flash-exp');
      final chat = model.startChat();

      // Provide a text prompt to include with the image
      final prompt = Content.text(
          "Analyze the uploaded image of a meal to determine if it is nutritionally balanced. Estimate the approximate calorie content and identify any missing nutrients that could enhance its overall nutritional value. Evaluate whether this meal is beneficial for PCOS by assessing its effects on insulin resistance, inflammation, and hormone balance. Provide recommendations for improvements if necessary.");

      // Read image bytes
      final imageBytes = await File(_image!.path).readAsBytes();
      final imagePart = Content.inlineData('image/jpeg', imageBytes);

      // To stream generated text output, call generateContentStream with the text and image
      final response = await model.generateContentStream([
        prompt, // Content.text already returns a Content object
        imagePart // Content.inlineData already returns a Content object
      ]);

      await for (final chunk in response) {
        if (chunk.text != null) {
          setState(() {
            _response += chunk.text!;
            _response = _response
                .replaceAll('###', '')
                .replaceAll('**', '')
                .replaceAll('##', '')
                .replaceAll('*', '•');
            if (_response.contains("Meal Components")) {
              _response =
                  _response.substring(_response.indexOf("Ingredients:"));
            }
          });
        }
      }
    } catch (e) {
      print("Error processing the image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check Ingredients',
          style: TextStyle(
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Intro text
            Text(
              'Upload an image of a meal, to analyze whether it is balanced, estimate its approximate calorie content, and suggest any additional nutrients that could improve its nutritional value.',
              style: TextStyle(
                  fontFamily: 'FunnelSans',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 74, 98, 138),
                  fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Center the button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 74, 98, 138),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FunnelSans'),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // If image is selected, show it and the "Get Recipe" button
            if (_image != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(_image!.path),
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _getRecipeFromImage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 74, 98, 138),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Check Meal',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FunnelSans'),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20.0),
            // Show recipe if available
            if (_response.isNotEmpty) ...[
              Card(
                color: Color.fromARGB(255, 74, 98, 138),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meals Result',
                        style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FunnelSans',
                              fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _response,
                        style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FunnelSans',
                              fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
