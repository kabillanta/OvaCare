import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class NewRoomPage extends StatefulWidget {
  final String story;
  final List<Uint8List> images;

  const NewRoomPage({Key? key, required this.story, required this.images})
      : super(key: key);

  @override
  _NewRoomPageState createState() => _NewRoomPageState();
}

class _NewRoomPageState extends State<NewRoomPage> {
 

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.stop();
    _timer.cancel();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Relaxation Room',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title and Carousel Slider for images
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Visual Journey',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'FunnelSans',
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: true,
                  ),
                  items: widget.images.map((image) {
                    return Image.memory(image);
                  }).toList(),
                ),

                // Title for the story section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Story Time',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'FunnelSans',
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),

                // Story content wrapped in SingleChildScrollView
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _displayedStory,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'FunnelSans',
                          color: const Color.fromARGB(255, 74, 98, 138)),
                    ),
                  ),
                ),

                // Generate Audio Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isGeneratingAudio || _isAudioPlaying
                        ? null
                        : _generateAudio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isGeneratingAudio
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Visibility(
                            visible: !_isGeneratingAudio,
                            child: const Text(
                              'Generate Audio',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'FunnelSans',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
