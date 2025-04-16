

import 'package:flutter/material.dart';
import 'sellers_dashboard.dart';
import 'sellers_messages.dart';
import 'sellers_wallet.dart';
import 'sellers_post_item.dart';
import 'login_seller.dart';

class SellersSettings extends StatefulWidget {
  @override
  _SellersSettingsState createState() => _SellersSettingsState();
}

class _SellersSettingsState extends State<SellersSettings> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _receiveNotifications = true;
  bool _isDarkMode = false;
  final _usernameController = TextEditingController();

  int _selectedIndex = 2; // Settings is index 2 in our BottomAppBar setup

  void _changePassword() {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password Changed Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
    }
  }

  // void _logOut() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Logged out successfully")),
  //   );
  // }

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
      // Already on Settings screen
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 This keeps the FAB fixed when keyboard appears

      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFF004D40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Profile Settings"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Change Username"),
                    content: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: "New Username"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Username Changed")),
                          );
                          Navigator.pop(context);
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Change Password"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Change Password"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _oldPasswordController,
                          decoration: InputDecoration(labelText: "Old Password"),
                          obscureText: true,
                        ),
                        TextField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(labelText: "New Password"),
                          obscureText: true,
                        ),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(labelText: "Confirm New Password"),
                          obscureText: true,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          _changePassword();
                          Navigator.pop(context);
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notification Preferences"),
              subtitle: Text(_receiveNotifications
                  ? "You will receive notifications"
                  : "You will not receive notifications"),
              onTap: () {
                setState(() {
                  _receiveNotifications = !_receiveNotifications;
                });
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text("Notification preferences updated")),
                // );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.palette),
              title: Text("Theme Settings"),
              subtitle: Text(_isDarkMode ? "Dark Mode" : "Light Mode"),
              onTap: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text("Theme updated")),
                // );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Log Out"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Confirm Logout"),
                    content: Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginSellerScreen()),
                                (route) => false, // Remove all previous routes
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            Divider(),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Terms & Conditions"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Terms & Conditions"),
                    content: Text("Here are the terms and conditions..."),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text("Privacy Policy"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Privacy Policy"),
                    content: Text("Here is the privacy policy..."),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.home, 0),
              _buildNavIcon(Icons.message, 1),
              SizedBox(width: 40), // space for FAB
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
        child: Icon(Icons.add, size: 30),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
