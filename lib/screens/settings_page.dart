
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xD9D9D9), // Background color

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // **Spacing to push the logo down**
          SizedBox(height: 70), // Adjust as needed

          // **Centered Logo**
          Center(
            child: Image.asset(
              'assets/app_logo_white.png',
              width: 100, // Adjust size if needed
              height: 100,
            ),
          ),

          SizedBox(height: 40), // Space below logo

          // **Settings Options**
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                settingsItem(Icons.person, "Profile settings", Colors.blue),
                settingsItem(Icons.lock, "Privacy and Security", Colors.red),
                settingsItem(Icons.notifications, "Notifications", Colors.yellow),
                settingsItem(Icons.help, "Get Help", Colors.green),
                settingsItem(Icons.attach_money, "Platform fees & Commission", Colors.purple),
                settingsItem(Icons.store, "Login As A Seller", Colors.brown),
                settingsItem(Icons.exit_to_app, "Logout", Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // **Reusable Widget for Settings Items with Icon Colors**
  Widget settingsItem(IconData icon, String title, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          // Handle tap event
        },
      ),
    );
  }
}
