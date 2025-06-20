

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Add a GlobalKey for the form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _sendPasswordResetEmail() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, stop here
    }

    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Check if email exists in either buyers or sellers collections
      bool emailExists = await _checkIfEmailExists(email);

      if (emailExists) {
        // Only send password reset email if the email exists in your database
        await _auth.sendPasswordResetEmail(email: email);
        _showMessage("Password reset email sent. Please check your inbox and spam folder.");
        _emailController.clear(); // Clear the field on success
      } else {
        // For security, it's often better to give a generic message
        // like "If an account exists, a reset email has been sent."
        // However, since you're explicitly checking, we'll stick to your logic
        // but make the message more informative.
        _showMessage("No account found with that email. Please check the email address you entered.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'user-not-found') {
        // This case might be hit if the email is not in Firebase Auth
        // but your Firestore check passed (less common if integrated well).
        errorMessage = 'No user found for that email address in our system.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      _showMessage(errorMessage);
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      _showMessage("An unexpected error occurred: ${e.toString()}");
      print("General Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkIfEmailExists(String email) async {
    // Check in both buyers and sellers collections
    // Assuming 'schoolEmail' is the field storing the email
    final buyerSnap = await _firestore
        .collection('users') // Assuming a unified 'users' collection with 'role' field
        .where('email', isEqualTo: email) // Use 'email' field as it's common
        .limit(1)
        .get();

    if (buyerSnap.docs.isNotEmpty) return true;

    // If you strictly have 'buyers' and 'sellers' as separate top-level collections
    // and store distinct user types, keep your original logic.
    // However, a single 'users' collection with a 'role' field is often more scalable.
    // If you ARE using separate collections, your original check was correct.
    // For this example, I'll assume 'users' collection.
    // If 'schoolEmail' is indeed the field, keep it as `where('schoolEmail', isEqualTo: email)`.
    // My previous answer for ProfileSettingsScreen also assumed 'email' for Firestore.
    // Let's go with 'email' for consistency for now.

    // If you have separate collections for 'buyers' and 'sellers':
    /*
    final sellerSnap = await _firestore
        .collection('sellers')
        .where('schoolEmail', isEqualTo: email)
        .limit(1)
        .get();
    return sellerSnap.docs.isNotEmpty;
    */
    // If you use a single 'users' collection, the first check is sufficient.
    return false; // If using single 'users' collection, this line won't be reached if email is found.
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Information"), // Changed from "Notice"
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form( // Wrap with Form for validation
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Forgot your password?",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10), // Reduced spacing
              const Text(
                "Enter your school email address below and we'll send you a password reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField( // Changed to TextFormField
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "School Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: "example@youruni.edu", // Added hint
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your school email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                onPressed: _sendPasswordResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Added border radius
                ),
                child: Text(
                  "Send Reset Link",
                  style: TextStyle(color: Colors.teal.shade700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}