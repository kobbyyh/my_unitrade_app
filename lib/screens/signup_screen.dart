
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'email_verification_screen.dart'; // Ensure this path is correct

class SignupScreen extends StatefulWidget {
  final String selectedUniversity;

  SignupScreen({required this.selectedUniversity});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final studentIdController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  // final otpController = TextEditingController(); // REMOVED: No longer needed for email verification

  String? allowedEmailDomain;
  bool domainLoading = true;
  // bool isEmailSent = false; // This state is now handled by navigating to EmailVerificationScreen
  // bool isVerifying = false; // This state is relevant to EmailVerificationScreen or Login, not direct signup
  bool isLoading = false; // To show loading state on signup button

  @override
  void initState() {
    super.initState();
    fetchUniversityDomain();
  }

  Future<void> fetchUniversityDomain() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(widget.selectedUniversity)
          .get();

      setState(() {
        allowedEmailDomain = doc['emailDomain'] ?? '';
        domainLoading = false;
      });
    } catch (e) {
      setState(() => domainLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load university email domain: ${e.toString()}')),
      );
    }
  }

  Future<void> _registerUserAndSendVerificationEmail() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields correctly.")),
      );
      return;
    }

    setState(() => isLoading = true); // Start loading

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Send email verification link
      await userCredential.user!.sendEmailVerification();

      // Navigate to the custom confirmation screen
      // The EmailVerificationScreen should then guide the user to check their email
      // and potentially offer a way to re-check verification status or resend email.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            fullName: fullNameController.text,
            email: emailController.text,
            studentId: studentIdController.text,
            phone: phoneController.text,
            university: widget.selectedUniversity,
            // Pass the userCredential.user to EmailVerificationScreen if needed for reload/resend logic
            firebaseUser: userCredential.user,
          ),
        ),
      );

      // Show success message (optional, as EmailVerificationScreen will guide)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent! Please check your inbox.')),
      );

    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Registration failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false); // Stop loading
    }
  }

  // NOTE: The checkEmailVerified function from your original code
  // is more appropriately used on the EmailVerificationScreen itself,
  // or on a login screen where the user attempts to log in before verification.
  // We don't call it directly after signup on this screen anymore.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: domainLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/app_logo.png', width: 100, height: 100),
                const SizedBox(height: 20),
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name (as per your school ID)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter full name" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "University Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return "Enter a valid email";
                    }
                    if (allowedEmailDomain != null && !value.endsWith('@$allowedEmailDomain')) {
                      return "Email must end with @$allowedEmailDomain";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: studentIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Student ID Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter your student ID"
                      : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter your phone number" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Primary Sign Up Button
                ElevatedButton(
                  onPressed: isLoading ? null : _registerUserAndSendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50), // Make button full width
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context), // Assuming pop goes back to login
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
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