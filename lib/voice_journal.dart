import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class VoiceJournalPage extends StatefulWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Journal',
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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Center all children horizontally
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center all children vertically
                  children: [
                    const Text(
                      'Add your journal for today',
                      style: TextStyle(
                          fontFamily: 'FunnelSans',
                          fontSize: 18,
                          color: const Color.fromARGB(255, 74, 98, 138),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _journalController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type your journal entry here...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                          fontFamily: 'FunnelSans', color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _addJournal(_journalController.text);
                          },
                          child: const Text(
                            'Save Journal',
                            style: TextStyle(
                                fontFamily: 'FunnelSans',
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 74, 98, 138),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                        IconButton(
                          onPressed: _startVoiceInput,
                          icon: const Icon(Icons.mic,
                              color: const Color.fromARGB(255, 74, 98, 138)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Old Journal Entries',
                      style: TextStyle(
                          fontFamily: 'FunnelSans',
                          fontSize: 18,
                          color: const Color.fromARGB(255, 74, 98, 138),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _journals.isEmpty
                        ? const Text(
                            'No saved journals. Start adding your entries.',
                            style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 74, 98, 138)),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _journals.length,
                              itemBuilder: (context, index) {
                                final journal = _journals[index];
                                final content =
                                    journal['content'] ?? 'No Content';
                                final timestamp =
                                    (journal['timestamp'] as Timestamp)
                                        .toDate();
                                final dateFormatted =
                                    DateFormat('yyyy-MM-dd').format(timestamp);

                                return Card(
                                  color: Colors.white,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    title: Text(
                                      content,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: 'FunnelSans'),
                                    ),
                                    subtitle: Text(dateFormatted,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchAndShowAnalytics,
                      child: const Text('Analytics',
                          style: TextStyle(
                              fontFamily: 'FunnelSans',
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 74, 98, 138),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
