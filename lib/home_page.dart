import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ovacare/smart_plate.dart';
import 'google_sign_in.dart';
import 'chat_bot_screen.dart';
import 'harmony_hub.dart';
import 'mind_sync.dart';
import 'lab_lens.dart';
import 'vital_flow.dart';
import 'community_connect.dart';
import 'wellness_plan.dart';
import 'doctor_connect.dart';
import 'support.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  // Sign out function
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GoogleSignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 74, 98, 138),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome! 👋',
                  style: TextStyle(
                      fontFamily: 'FunnelSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  user.displayName ?? 'No Name',
                  style: const TextStyle(
                      fontFamily: 'FunnelSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Your Personalized Path to PCOS Wellness 💙',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 74, 98, 138),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildFeatureTile(
                      'ChatBot', 'assets/images/chatbot_logo.png', context),
                  _buildFeatureTile('Vital Flow',
                      'assets/images/vitals_tracker_logo.png', context),
                  _buildFeatureTile(
                      'Smart Plate', 'assets/images/smart_plate.png', context),
                  _buildFeatureTile(
                      'Harmony Hub', 'assets/images/harmony_hub.png', context),
                  _buildFeatureTile(
                      'Mind Sync', 'assets/images/mind_sync.png', context),
                  _buildFeatureTile(
                      'Lab Lens', 'assets/images/lab_lens.png', context),
                  _buildFeatureTile('Community Connect',
                      'assets/images/community_connect.png', context),
                  _buildFeatureTile('Wellness Plan',
                      'assets/images/wellness_plan.png', context),
                  _buildFeatureTile('Doctor Sync',
                      'assets/images/doctor-connect.png', context),
                  _buildFeatureTile(
                      'Support', 'assets/images/guide.png', context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
      String title, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'ChatBot') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        } else if (title == 'Smart Plate') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SmartPlatePage()),
          );
        } else if (title == 'Harmony Hub') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HarmonyHubPage()),
          );
        } else if (title == 'Mind Sync') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MindSyncPage()),
          );
        } else if (title == 'Lab Lens') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LabLens()),
          );
        } else if (title == 'Vital Flow') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VitalFlowPage()),
          );
        } else if (title == 'Community Connect') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityConnectPage()),
          );
        } else if (title == 'Wellness Plan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WellnessPlan()),
          );
        } else if (title == 'Doctor Sync') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorConnectPage()),
          );
        } else if (title == 'Support') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SupportPage()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 196, 215, 224),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 90, width: 90, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'FunnelSans',
                color: Color.fromARGB(255, 30, 42, 94),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
