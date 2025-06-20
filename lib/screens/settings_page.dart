

import 'package:UniTrade/screens/get_help.dart';
import 'package:UniTrade/screens/notifications.dart';
import 'package:UniTrade/screens/platform_fees.dart';
import 'package:UniTrade/screens/privacy_and_security.dart';
import 'package:UniTrade/screens/profile_settings.dart';
import 'package:UniTrade/screens/signup_seller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'university_selection.dart'; // Import University Selection screen

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSeller = false; // Temporary variable to simulate seller status

  // Logout method
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      // Navigate to the University Selection Screen (to provide security)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UniversitySelection()),
            // UniversitySelectionScreen()),
      );
    } catch (e) {
      // Handle errors if needed
      _showMessage(context, 'Error during logout: ${e.toString()}');
    }
  }

  // Method to show messages (in case of errors)
  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notice'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xD9D9D9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 70),
          Center(
            child: Image.asset(
              'assets/app_logo.png',
              width: 100,
              height: 100,
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                settingsItem(context, Icons.person, "Profile settings", Colors.blue, ProfileSettingsScreen()),
                settingsItem(context, Icons.lock, "Privacy and Security", Colors.red, PrivacyAndSecurityScreen()),
                settingsItem(context, Icons.notifications, "Notifications", Colors.yellow, NotificationsScreen()),
                settingsItem(context, Icons.attach_money, "Platform Fees & Commission", Colors.purple, PlatformFeesScreen()),

                // 🔹 Login As A Seller (Modified Logic)
                ListTile(
                  leading: Icon(Icons.store, color: Colors.brown),
                  title: Text("Login As A Seller", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () {
                    if (isSeller) {
                      // If user is already a seller, go to Seller Dashboard (placeholder)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlaceholderScreen(title: "Seller Dashboard")),
                      );
                    } else {
                      // If user is NOT a seller, go to Seller Signup Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SellerSignupScreen()),
                      );
                    }
                  },
                ),

                // 🔹 Logout Button
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.orange),
                  title: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  // onTap: () => _logout(context), // Call logout method here
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm Logout"),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text("Yes"),
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                              _logout(context); // Call the Firebase logout method
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Embed GetHelpSection directly
                GetHelpSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Reusable Widget for Settings Items
  Widget settingsItem(BuildContext context, IconData icon, String title, Color iconColor, Widget? page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        onTap: page != null
            ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        }
            : null, // If no page assigned, do nothing
      ),
    );
  }
}

// 🔹 Placeholder Screen (for Seller Dashboard)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("This is a placeholder for $title")),
    );
  }
}
