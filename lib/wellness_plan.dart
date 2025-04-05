import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WellnessPlan extends StatefulWidget {
  const WellnessPlan({super.key});

  @override
  _WellnessPlanState createState() => _WellnessPlanState();
}

class _WellnessPlanState extends State<WellnessPlan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wellness Plan',
          style: TextStyle(
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: _hasPlanForToday ? _buildTodoListPage() : _buildForm(),
    );
  }

  Widget _buildForm(){
    return SingleChildScrollView(
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
                  labelText: 'Add a note about your day',
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
                    return 'Please enter the note.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _suggestion,
                decoration: InputDecoration(
                  labelText: 'Lifestyle Suggestions',
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
                items: _suggestionOptions.map((String option) {
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
                    _suggestion = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _energyLevel,
                decoration: InputDecoration(
                  labelText: 'Current Energy Level',
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
                items: _energyLevels.map((String option) {
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
                    _energyLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _wellnessGoal,
                decoration: InputDecoration(
                  labelText: 'Wellness Goals for the day',
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
                items: _wellnessGoals.map((String option) {
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
                    _wellnessGoal = value!;
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
                child: const Text('Generate Wellness Plan'),
              ),
              const SizedBox(height: 20.0),
              if (isLoading) ...[
                const SizedBox(height: 20.0),
                const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 74, 98, 138))),
              ],
            ],
          ),
        ),
      );
  }

 Widget _buildTodoListPage() {
  return Column(
    children: [
      // Gamification: Fixed points & progress
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "🏆 Points: 50",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.5, // Hardcoded to show 50% progress
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            const Text(
              "Keep going! You're doing great! 🎯",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ],
        ),
      ),

      // Existing To-Do List
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _todoList.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              elevation: 3,
              child: ListTile(
                title: Text(
                  _todoList[index]['title'] ?? "Untitled Task",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FunnelSans',
                      color: Color.fromARGB(255, 74, 98, 138)),
                ),
                subtitle: Text(
                  _todoList[index]['description'] ?? "No description available",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}



}
