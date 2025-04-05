import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class NewYogaPage extends StatefulWidget {
  final String story;
  final List<Uint8List> images;

  const NewYogaPage({Key? key, required this.story, required this.images})
      : super(key: key);

  @override
  _NewYogaPageState createState() => _NewYogaPageState();
}

class _NewYogaPageState extends State<NewYogaPage> {
 

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _audioPlayer = AudioPlayer();

    _flutterTts.setVoice({'locale': 'en-IN'});
    _flutterTts.setSpeechRate(0.4); // Slow pace of speech
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yoga',
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
                    'Yoga Pose',
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
                              'Start Instructions',
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
