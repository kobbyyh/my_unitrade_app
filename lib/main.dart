import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: Color(0xFF004D40), // Teal background
            ),
            home: SplashScreen(), // Start with the Splash Screen
        );
    }
}
