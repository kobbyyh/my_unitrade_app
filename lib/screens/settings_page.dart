
import 'package:flutter/material.dart';
import 'profile_settings.dart';
import 'privacy_and_security.dart';
import 'notifications.dart';
import 'get_help.dart'; // Import GetHelpSection
import 'platform_fees.dart';
import 'signup_seller.dart'; // Import Seller Signup Screen

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSeller = false; // Temporary variable to simulate seller status

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

                settingsItem(context, Icons.exit_to_app, "Logout", Colors.orange, null),

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
