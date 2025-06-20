import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Only if you store additional profile data

class SellerProfileSettingsScreen extends StatefulWidget {
  @override
  _SellerProfileSettingsScreenState createState() => _SellerProfileSettingsScreenState();
}

class _SellerProfileSettingsScreenState extends State<SellerProfileSettingsScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // To display current email (read-only)
  // final _phoneController = TextEditingController(); // Uncomment if you have a phone field
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Function to load existing user profile data
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // Display current display name (if available) or a default
        _usernameController.text = user.displayName ?? '';
        // Display current email (read-only)
        _emailController.text = user.email ?? 'No email available';
        // If you store phone or other data in Firestore:
        // You would fetch it here:
        // FirebaseFirestore.instance.collection('sellers').doc(user.uid).get().then((doc) {
        //   if (doc.exists) {
        //     _phoneController.text = doc.data()?['phone'] ?? '';
        //   }
        // });
      });
    }
  }

  // Function to update user profile in Firebase
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update display name in Firebase Authentication
        await user.updateDisplayName(_usernameController.text.trim());

        // If you need to update other profile details in Firestore:
        // await FirebaseFirestore.instance.collection('sellers').doc(user.uid).update({
        //   'username': _usernameController.text.trim(),
        //   // 'phone': _phoneController.text.trim(), // Uncomment if saving phone
        // });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context); // Go back to settings screen
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    // _phoneController.dispose(); // Uncomment if you have a phone field
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              readOnly: true, // Email is typically not changed via this screen
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            // const SizedBox(height: 20), // Uncomment if you have a phone field
            // TextFormField(
            //   controller: _phoneController, // Uncomment if you have a phone field
            //   decoration: const InputDecoration(
            //     labelText: "Phone Number",
            //     border: OutlineInputBorder(),
            //     prefixIcon: Icon(Icons.phone),
            //   ),
            //   keyboardType: TextInputType.phone,
            // ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}