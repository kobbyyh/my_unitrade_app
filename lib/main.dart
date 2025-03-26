import 'package:flutter/material.dart';
import 'splashScreen.dart'; // Import your SplashScreen

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Your App Title', // Replace with your app's title
            home: const SplashScreen(), // Use SplashScreen as the home screen
        );
    }
}