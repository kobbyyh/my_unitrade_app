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

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Please enter your email.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool emailExists = await _checkIfEmailExists(email);

      if (emailExists) {
        await _auth.sendPasswordResetEmail(email: email);
        _showMessage("Password reset email sent. Check your inbox.");
      } else {
        _showMessage("No account found with that email.");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _checkIfEmailExists(String email) async {
    // Check in both buyers and sellers collections
    final buyerSnap = await _firestore
        .collection('buyers')
        .where('schoolEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (buyerSnap.docs.isNotEmpty) return true;

    final sellerSnap = await _firestore
        .collection('sellers')
        .where('schoolEmail', isEqualTo: email)
        .limit(1)
        .get();

    return sellerSnap.docs.isNotEmpty;
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Notice"),
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
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "School Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              child: Text(
                "Send Reset Link",
                style: TextStyle(color: Colors.teal.shade700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
