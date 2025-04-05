import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:googleapis/securitycenter/v1.dart';
import 'google_tts_service.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'google_translate_service.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMeditationPage extends StatefulWidget {
  final String story;
  final String language;
  final String mood;
  final String focus;

  const NewMeditationPage({
    Key? key,
    required this.story,
    required this.language,
    required this.mood,
    required this.focus,
  }) : super(key: key);

  @override
  _NewMeditationPageState createState() => _NewMeditationPageState();
}

class _NewMeditationPageState extends State<NewMeditationPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Meditation',
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image that covers a major chunk of the screen
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.4, // 40% of the screen height
                  child: Image.asset(
                    'assets/images/harmony_hub.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                // Identical buttons
                _buildButton(
                  'Start Meditating',
                  _isGeneratingAudio
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                  _speakStory,
                ),
                const SizedBox(height: 20),
                _buildButton(
                  'Download Session',
                  _isDownloading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                  _downloadSession,
                ),
                const SizedBox(height: 20),
                _buildButton(
                  'Save Session',
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                  _saveSession,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Helper method to create buttons
  Widget _buildButton(
      String label, Widget? loadingIndicator, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 74, 98, 138),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loadingIndicator ??
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'FunnelSans',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
}
