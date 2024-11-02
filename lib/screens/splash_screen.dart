import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:talkloop/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to AuthenticationWrapper after 5 seconds
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthenticationWrapper()),
      ),
    );
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set a background color for your splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/Splash_lottie.json', // Path to your Lottie JSON file
              width: 200, // Adjust width and height as needed
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20), // Space between animation and text
            const Text(
              "Talk Loooooooop",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 104, 3, 58), // Change to your preferred color
                fontFamily: 'Pacifico', // Choose a stylish font, like Pacifico
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
