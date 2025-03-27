
import 'package:flutter/material.dart';
import 'screens/university_selection.dart';  // Import the university selection screen

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: Color(0xFF004D40), // Teal color
            ),
            home: UniversitySelection(), // Start with university selection
        );
    }
}
