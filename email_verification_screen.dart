
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for User object
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import 'package:lottie/lottie.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String studentId;
  final String phone;
  final String university;
  final User? firebaseUser; // Now receiving the User object

  EmailVerificationScreen({
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.phone,
    required this.university,
    this.firebaseUser, // Make it nullable in the constructor
  });

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isCheckingVerification = false;
  bool isResendingEmail = false;

  // We should ideally use the actual Firebase User object here
  // If firebaseUser is null, it means there was an issue passing it,
  // or the user navigated here incorrectly. We can fall back to FirebaseAuth.instance.currentUser
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.firebaseUser ?? FirebaseAuth.instance.currentUser;
    // Potentially start a timer here to periodically check verification status
    // For simplicity, we'll rely on button clicks for now.
  }

  Future<void> _checkEmailVerificationStatus() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active user found. Please re-login.')),
      );
      return;
    }

    setState(() => isCheckingVerification = true);
    try {
      // Reload the user to get the latest email verification status
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser; // Get the reloaded user object

      if (_user != null && _user!.emailVerified) {
        // Email is verified! Now save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
          'fullName': widget.fullName,
          'email': widget.email.trim(),
          'studentId': widget.studentId,
          'phone': widget.phone,
          'userType': 'buyer', // Default user type
          'university': widget.university,
          'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
        });

        // Navigate to HomeScreen and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      } else {
        // Email not verified yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
        );
      }
    } catch (e) {
      print("Error checking verification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check verification status: ${e.toString()}')),
      );
    } finally {
      setState(() => isCheckingVerification = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active user to resend email to.')),
      );
      return;
    }
    if (_user!.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your email is already verified!')),
      );
      return;
    }

    setState(() => isResendingEmail = true);
    try {
      await _user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent! Please check your inbox.')),
      );
    } catch (e) {
      print("Error resending email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend verification email: ${e.toString()}')),
      );
    } finally {
      setState(() => isResendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Center(
            child: Text('Email verification in progress...')),
                // Lottie.asset(
                //   'assets/book.jpg', // Ensure this Lottie animation path is correct
                //   width: 200,
                //   repeat: true,
                // ),
                const SizedBox(height: 20),
                Text(
                  "Verify Your Email",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "A verification link has been sent to:\n${widget.email}\n\nPlease click the link in your email to verify your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 30),

                // Removed OTP input field and 'Send OTP' button

                ElevatedButton(
                  onPressed: isCheckingVerification ? null : _checkEmailVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCheckingVerification ? "Checking..." : "I've Verified My Email",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: isResendingEmail || isCheckingVerification ? null : _resendVerificationEmail,
                  child: Text(
                    isResendingEmail ? "Resending..." : "Resend Verification Email",
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}