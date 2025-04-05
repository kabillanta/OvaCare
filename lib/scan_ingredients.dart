// ignore_for_file: all

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To pick images from gallery or camera
import 'package:firebase_vertexai/firebase_vertexai.dart'; // For using Gemini API
import 'dart:io'; // For file handling

class ScanIngredients extends StatefulWidget {

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
              'Upload a clear image of the ingredient list to check for PCOS-friendly and harmful ingredients. We’ll help you spot added sugars, preservatives, and inflammatory additives to support your health journey.',
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
                        'Check Recipe',
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
                        'Ingredients Result',
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
