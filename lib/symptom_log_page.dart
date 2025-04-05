import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class SymptomLogPage extends StatefulWidget {
  const SymptomLogPage({Key? key}) : super(key: key);

  @override
  _SymptomLogPageState createState() => _SymptomLogPageState();
}

class _SymptomLogPageState extends State<SymptomLogPage> {
  @override
  void initState() {
    super.initState();
    for (var symptom in symptoms) {
      symptomSeverity[symptom] = 1.0;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Symptom Log",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'FunnelSans',
            color: Colors.white, // White text
          ),
        ),
        backgroundColor: const Color(0xFF4A628A),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249), // White background
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PCOS Symptom Insights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'FunnelSans',
                color: Color(0xFF4A628A), // Text in Color(0xFF4A628A)
              ),
            ),
            const SizedBox(height: 12),
            _insights.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              Color(0xFF4A628A)), // Border in Color(0xFF4A628A)
                    ),
                    child: Text(
                      _insights,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'FunnelSans',
                        color: Colors.black, // Text in black
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            if (showPastLogs && pastLogs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Past Symptom Logs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FunnelSans',
                      color: Color(0xFF4A628A), // Text in Color(0xFF4A628A)
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...pastLogs.map((log) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: log['bgColor'],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "${log['symptom']}: Avg Severity - ${log['avgSeverity'].toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'FunnelSans',
                          color: Colors.black
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => showPastLogs = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF4A628A), // Button in Color(0xFF4A628A)
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Center(
                      child: Text(
                        "Log New Symptoms",
                        style: TextStyle(
                          color: Colors.white, // Button text in white
                          fontSize: 16,
                          fontFamily: 'FunnelSans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!showPastLogs)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Log Your Symptoms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FunnelSans',
                      color: Color(0xFF4A628A), // Text in Color(0xFF4A628A)
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...symptoms.map((symptom) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symptom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'FunnelSans',
                            color: Colors.black, // Text in black
                          ),
                        ),
                        Slider(
                          value: symptomSeverity[symptom]!,
                          min: 1,
                          max: 3,
                          divisions: 2,
                          activeColor: symptomSeverity[symptom] == 1
                              ? const Color(0xFFD4EDDA) // Pastel Green for Mild
                              : symptomSeverity[symptom] == 2
                                  ? const Color(
                                      0xFFFFF3CD) // Pastel Yellow for Moderate
                                  : const Color(
                                      0xFFF8D7DA), // Slider active track in Color(0xFF4A628A)
                          inactiveColor:
                              Colors.black, // Slider inactive track in black
                          thumbColor: Colors.black, // Thumb in black
                          label: symptomSeverity[symptom] == 1
                              ? "Mild"
                              : symptomSeverity[symptom] == 2
                                  ? "Moderate"
                                  : "Severe",
                          onChanged: (value) {
                            setState(() {
                              symptomSeverity[symptom] = value;
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Add notes (optional)...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => notes = value,
                    style: const TextStyle(
                        color: Colors.black), // Text input in black
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: logSymptoms,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                                0xFF4A628A), // Button in Color(0xFF4A628A)
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Center(
                            child: Text(
                              "Log Symptoms",
                              style: TextStyle(
                                color: Colors.white, // Button text in white
                                fontSize: 16,
                                fontFamily: 'FunnelSans',
                              ),
                            ),
                          ),
                        ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
