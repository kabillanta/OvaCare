import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'google_sign_in.dart'; 
import 'package:firebase_app_check/firebase_app_check.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,   
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OvaCare',
      theme: ThemeData.dark(),
      home: const GoogleSignInPage(),  
    );
  }
}