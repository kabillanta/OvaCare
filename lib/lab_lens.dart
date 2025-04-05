import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';

class LabLens extends StatefulWidget {
  const LabLens({super.key});

  @override
  _LabLensState createState() => _LabLensState();
}

class _LabLensState extends State<LabLens> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LabLens',
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/lab_lens.png', height: 150),
                const SizedBox(height: 20),
                const Text(
                  'Upload your lab report and get an AI-powered analysis!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'FunnelSans',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                _buildButton(
                  context,
                  'Upload Lab Report',
                  const Color.fromARGB(255, 74, 98, 138),
                  _pickPDF,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                if (_geminiResponse.isNotEmpty)
                  _buildButton(
                    context,
                    'Download Analysis Report',
                    const Color.fromARGB(255, 116, 153, 216),
                    () => _generatePdf(
                        _geminiResponse), // Corrected function call
                  ),
                if (_geminiResponse.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_geminiResponse, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'FunnelSans', color: Color.fromARGB(255, 74, 98, 138)),),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onTap) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: TextButton(
        onPressed: onTap,
        child: Text(text,
            style: const TextStyle(
                fontSize: 18, fontFamily: 'FunnelSans', color: Colors.white)),
      ),
    );
  }
}
