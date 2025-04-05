import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DoctorConnectPage extends StatefulWidget {
  @override
  _DoctorConnectPageState createState() => _DoctorConnectPageState();
}

class _DoctorConnectPageState extends State<DoctorConnectPage> {


  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _fetchMedicationData();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Sync',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
        elevation: 4,
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 20),
            _buildMedicationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 190, 209, 232),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoText("📅 Next Appointment", appointmentDate, const Color.fromARGB(255, 74, 98, 138)),
          const SizedBox(height: 8),
          _infoText("📝 Prescription", prescription, Colors.black87),
        ],
      ),
    );
  }

  Widget _infoText(String title, String value, Color color) {
    return RichText(
      text: TextSpan(
        text: "$title: ",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return Expanded(
      child: medicines.isEmpty
          ? const Center(child: Text("No medications prescribed.", style: TextStyle(fontSize: 16)))
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return _buildMedicineCard(medicines[index]);
              },
            ),
    );
  }

  Widget _buildMedicineCard(Map<String, String> medicine) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: const Color.fromARGB(255, 190, 209, 232),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 74, 98, 138),
          child: const Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(
          medicine['name']!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'FunnelSans',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "Quantity: ${medicine['quantity']}",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
