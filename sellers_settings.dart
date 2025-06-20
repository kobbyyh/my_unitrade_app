


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for logout
import 'sellers_dashboard.dart';
import 'sellers_messages.dart';
import 'sellers_wallet.dart';
import 'sellers_post_item.dart';
import 'login_seller.dart';

// NEW IMPORTS for the separate settings screens
import 'seller_profile_settings_screen.dart';
import 'seller_change_password_screen.dart';


class SellersSettings extends StatefulWidget {
  @override
  _SellersSettingsState createState() => _SellersSettingsState();
}

class _SellersSettingsState extends State<SellersSettings> {
  // Removed password and username controllers as they are now in separate screens
  // final _oldPasswordController = TextEditingController();
  // final _newPasswordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();
  // final _usernameController = TextEditingController();

  bool _receiveNotifications = true;
  bool _isDarkMode = false;

  int _selectedIndex = 2; // Settings is index 2 in our BottomAppBar setup

  // Removed _changePassword method as it's now in a separate screen


  // Modified _logOut to use Firebase signOut
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );
      // Navigate to login screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginSellerScreen()),
            (route) => false, // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellerDashboard()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellersMessages()));
        break;
      case 2:
      // Already on Settings screen, no navigation needed
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellersWallet()));
        break;
    }
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.white70,
        size: 30,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }

  @override
  void dispose() {
    // Only dispose controllers that are still in THIS widget.
    // The controllers for username and password are now disposed in their respective screens.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Keep this false for fixed FAB/BottomAppBar

      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Profile Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerProfileSettingsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerChangePasswordScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notification Preferences"),
              subtitle: Text(_receiveNotifications
                  ? "You will receive notifications"
                  : "You will not receive notifications"),
              onTap: () {
                setState(() {
                  _receiveNotifications = !_receiveNotifications;
                });
              },
            ),

            // const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.palette),
            //   title: const Text("Theme Settings"),
            //   subtitle: Text(_isDarkMode ? "Dark Mode" : "Light Mode"),
            //   onTap: () {
            //     setState(() {
            //       _isDarkMode = !_isDarkMode;
            //     });
            //   },
            // ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Log Out"),
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
                          _logOut(); // Call the Firebase logout method
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text("Terms & Conditions"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Terms & Conditions"),
                    content: const Text('Welcome to UniTrade! These Terms of Service ("Terms") govern your access to and use of the UniTrade mobile application (the "App" or "Service"). UniTrade is designed to connect university students for the buying and selling of goods and services within their university community.'
                        'By downloading, installing, accessing, or using the UniTrade App, you acknowledge that you have read, understood, and agree to be bound by these Terms, as well as our Privacy Policy. If you do not agree with any part of these Terms, you may not access or use the Service.'

                        'These Terms constitute a legally binding agreement between you and UniTrade. We reserve the right to modify these Terms at any time. Your continued use of the App following any such modifications signifies your acceptance of the updated Terms. We encourage you to review these Terms regularly.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Privacy Policy"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Privacy Policy"),
                    content: const Text('We are committed to protecting your privacy and ensuring the security of your personal data. By using the UniTrade App, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree with the terms outlined in this policy, please do not use the UniTrade App.'
                        'This policy applies to all users of the UniTrade App, including buyers and sellers, and covers data collected through your interactions with the App, its services, and any related communications. Our goal is to provide a safe and reliable platform for university students to buy and sell items within their university community.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.home, 0),
              _buildNavIcon(Icons.message, 1),
              const SizedBox(width: 40), // space for FAB
              _buildNavIcon(Icons.settings, 2),
              _buildNavIcon(Icons.account_balance_wallet, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SellerPostItem()));
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, size: 30),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}