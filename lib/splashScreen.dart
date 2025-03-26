import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Replace with your actual logo)
            Image.asset(
              'assets/images/app_logo.png', // Replace with your logo path
              width: 150, // Adjust the width as needed
              height: 150, // Adjust the height as needed
            ),
            const SizedBox(height: 24), // Spacing between logo and app name
            // App Name
            const Text(
              'Your App Name', // Replace with your app's name
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set your desired text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}