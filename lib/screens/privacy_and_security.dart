
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class PrivacyAndSecurityScreen extends StatefulWidget {
  @override
  _PrivacyAndSecurityScreenState createState() => _PrivacyAndSecurityScreenState();
}

class _PrivacyAndSecurityScreenState extends State<PrivacyAndSecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Controllers for the password change dialog fields
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  // GlobalKey for the form inside the dialog for validation
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // Function to show the password change dialog
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext dialogContext) { // Use dialogContext for navigation within dialog
        return AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _oldPasswordController,
                    decoration: const InputDecoration(labelText: "Old Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your old password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(labelText: "New Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) { // Firebase requires at least 6 characters
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: const InputDecoration(labelText: "Confirm New Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _clearPasswordFields();
              },
            ),
            ElevatedButton(
              onPressed: () => _handleChangePassword(dialogContext), // Pass dialog context
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
              ),
              child: const Text("Change", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to handle password change logic
  Future<void> _handleChangePassword(BuildContext dialogContext) async {
    if (!_passwordFormKey.currentState!.validate()) {
      return; // If validation fails, do nothing
    }

    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.of(dialogContext).pop(); // Close dialog
      _showResultDialog("Error", "No user is currently logged in.");
      return;
    }

    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;

    try {
      // Re-authenticate user with old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, // Assumes email is not null (users signed in with email/password)
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // If re-authentication successful, update password
      await user.updatePassword(newPassword);

      Navigator.of(dialogContext).pop(); // Close the password change dialog
      _showResultDialog("Success", "Your password has been changed successfully!");
      _clearPasswordFields();

    } on FirebaseAuthException catch (e) {
      Navigator.of(dialogContext).pop(); // Close password change dialog
      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = 'Your old password is incorrect.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'This operation is sensitive and requires recent authentication. Please log out and log in again.';
      } else if (e.code == 'invalid-credential') { // Sometimes thrown for wrong password
        errorMessage = 'Invalid credentials. Please check your old password.';
      }
      else {
        errorMessage = 'Failed to change password: ${e.message}';
      }
      _showResultDialog("Error", errorMessage);
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      Navigator.of(dialogContext).pop(); // Close password change dialog
      _showResultDialog("Error", "An unexpected error occurred: ${e.toString()}");
      print("General Error: $e");
    }
  }

  // Helper to show success/error pop-up
  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the result dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to clear password fields after attempt
  void _clearPasswordFields() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
        title: const Text("Privacy & Security"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700!, Colors.teal.shade600!], // Background gradient
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
                onTap: _showChangePasswordDialog, // Call the dialog function
              ),
              const Divider(color: Colors.white54),
              // Add other privacy/security options here if needed
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
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: onTap,
    );
  }
}