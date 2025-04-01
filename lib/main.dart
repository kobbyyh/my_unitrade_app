
import 'package:flutter/material.dart';
import 'screens/university_selection.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/wallet_page.dart';
import 'screens/settings_page.dart';
import 'screens/chat_page.dart';
import 'screens/profile_settings.dart';
import 'screens/privacy_and_security.dart';
import 'screens/notifications.dart';
import 'screens/get_help.dart';
import 'screens/platform_fees.dart';
import 'screens/signup_seller.dart';
import 'screens/login_screen.dart';
import 'screens/login_seller.dart';



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
