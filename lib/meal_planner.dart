import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
 
  bool isLoading = false;
  @override
  void initState() {
    super.initState(); // Initialize Firebase when the page loads
  }

  // Initialize Firebase
  // Function to trigger chat and get a response from Vertex AI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Planner',
          style: TextStyle(
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: SingleChildScrollView(
        // Wrap the entire body in a scrollable widget
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans'), // White text color
                decoration: InputDecoration(
                  labelText: 'Number of Days',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 74, 98, 138),
                      fontFamily: 'FunnelSans'), // White label
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Color.fromARGB(255, 74, 98, 138)), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 74, 98, 138)), // White focus border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 74, 98, 138)), // White border when enabled
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of days.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans'), // White text color
                decoration: InputDecoration(
                  labelText: 'Calorie Requirement (kcal/day)',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 74, 98, 138),
                      fontFamily: 'FunnelSans'), // White label
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Color.fromARGB(255, 74, 98, 138)), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 74, 98, 138)), // White focus border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 74, 98, 138)), // White border when enabled
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your calorie requirement.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _dietType,
                decoration: InputDecoration(
                  labelText: 'Diet Type',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138), width: 2),
                  ),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color.fromARGB(255, 74, 98, 138),
                ),
                items: _dietOptions.map((String option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dietType = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _foodPreference,
                decoration: InputDecoration(
                  labelText: 'Food Preference',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138), width: 2),
                  ),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color.fromARGB(255, 74, 98, 138),
                ),
                items: _foodPreferences.map((String option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _foodPreference = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _cuisine,
                decoration: InputDecoration(
                  labelText: 'Cuisine',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 74, 98, 138), width: 2),
                  ),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color.fromARGB(255, 74, 98, 138),
                ),
                items: _cuisineOptions.map((String option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cuisine = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await _getChatResponse();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 74, 98, 138), // Text color
                ),
                child: const Text('Generate Meal Plan'),
              ),
              const SizedBox(height: 20.0),
              if (isLoading) ...[
                const SizedBox(height: 20.0),
                const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 74, 98, 138))),
              ],
              if (_response.isNotEmpty) ...[
                Card(
                  elevation: 4.0,
                  color: Color.fromARGB(255, 74, 98, 138),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Meal Plan:',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FunnelSans',
                              fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _response,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'FunnelSans',
                              fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    await _generatePdf(
                        _response); // Generate PDF and trigger download
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color.fromARGB(255, 74, 98, 138), // Text color
                  ),
                  child: const Text('Download Meal Plan as PDF'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
