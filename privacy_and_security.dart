import 'package:flutter/material.dart';

class PrivacyAndSecurityScreen extends StatefulWidget {
  @override
  _PrivacyAndSecurityScreenState createState() => _PrivacyAndSecurityScreenState();
}

class _PrivacyAndSecurityScreenState extends State<PrivacyAndSecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 77, 64, 1),
        title: Text("Privacy & Security"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.teal.shade600], // Background gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionTile(
                icon: Icons.lock,
                title: "Change Password",
                onTap: () {
                  // Navigate to change password screen
                },
              ),
              Divider(color: Colors.white54),
              _buildOptionTile(
                icon: Icons.block,
                title: "Blocked Accounts",
                onTap: () {
                  // Navigate to blocked accounts screen
                },
              ),
              Divider(color: Colors.white54),
              _buildOptionTile(
                icon: Icons.delete_forever,
                title: "Delete My Account",
                onTap: () {
                  // Handle account deletion
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white, fontSize: 16),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: onTap,
    );
  }
}
