//
//
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// class SellerSignupScreen extends StatefulWidget {
//   @override
//   _SellerSignupScreenState createState() => _SellerSignupScreenState();
// }
//
// class _SellerSignupScreenState extends State<SellerSignupScreen> {
//   File? _profileImage;
//   final picker = ImagePicker();
//
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _schoolIDController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _hostelController = TextEditingController();
//
//   bool _agreeToTerms = false;
//
//   // Firebase instances
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   // Function to pick image from gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   // Sign-up method
//   Future<void> _signUp() async {
//     if (_passwordController.text != _confirmPasswordController.text) {
//       _showError("Passwords do not match!");
//       return;
//     }
//
//     try {
//       User? user;
//       String uid;
//       String profileImageUrl = "";
//
//       // 1. Check if an account with this email already exists in Firebase Auth
//       // We can try to sign in with the email/password to see if it's already an existing user.
//       // Or, a safer way for signup, is to check if the user is already logged in (if they are, they are likely a buyer).
//       // If the user isn't logged in, we try to create an account.
//       // If they are logged in, we assume they are converting their account to seller.
//
//       if (_auth.currentUser != null && _auth.currentUser!.email == _emailController.text) {
//         // User is already logged in with this email, likely a buyer converting to seller
//         user = _auth.currentUser;
//         uid = user!.uid;
//         _showSuccessDialog("You are already logged in. Updating your account to Seller status.");
//
//       } else {
//         // Try to create a new user. If email is already in use, Firebase Auth will throw an error.
//         try {
//           UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//             email: _emailController.text,
//             password: _passwordController.text,
//           );
//           user = userCredential.user;
//           uid = user!.uid;
//           await user.sendEmailVerification(); // Send verification for new users
//
//         } on FirebaseAuthException catch (e) {
//           if (e.code == 'email-already-in-use') {
//             // This email is already registered in Firebase Auth.
//             // At this point, we assume they are an existing buyer trying to become a seller.
//             // We need to re-authenticate them to confirm they own the email/password.
//             _showError("An account with this email already exists. Please login if you want to update your account to seller, or use a different email to register a new account.");
//             return; // Exit signup process, user should log in first.
//           } else {
//             _showError(e.message ?? "An error occurred during account creation.");
//             return; // Exit signup process
//           }
//         }
//       }
//
//       // If we reach here, we either created a new user or identified an existing user.
//       // Now, handle profile image upload and Firestore data update/creation.
//
//       // Upload profile image (if provided)
//       if (_profileImage != null) {
//         final uploadTask = await _storage.ref('profile_images/$uid.jpg').putFile(_profileImage!);
//         profileImageUrl = await uploadTask.ref.getDownloadURL();
//       }
//
//       // Store or update user information in Firestore
//       // Use .set() with merge: true to update if document exists, or create if it doesn't.
//       await _firestore.collection('users').doc(uid).set({
//         'fullName': _fullNameController.text,
//         'username': _usernameController.text,
//         'schoolID': _schoolIDController.text,
//         'email': _emailController.text,
//         'phone': _phoneController.text,
//         'hostel': _hostelController.text,
//         'userType': 'seller', // Crucially set/update userType to seller
//         'profileImage': profileImageUrl,  // Update the image URL if available
//         'emailVerified': user?.emailVerified ?? false, // Update email verification status
//       }, SetOptions(merge: true)); // Use merge: true to update existing fields without overwriting others
//
//       // After successful sign up/update, show a success message
//       _showSuccessDialog("Seller account successfully set up! Please verify your email if you haven't already. You can now log in as a seller.");
//
//       // Pop back to the previous screen (e.g., login screen)
//       Navigator.pop(context);
//
//     } on FirebaseAuthException catch (e) {
//       // This catch block handles any FirebaseAuth errors not caught by the specific 'email-already-in-use' check
//       _showError(e.message ?? "An authentication error occurred.");
//     } catch (e) {
//       _showError("An unexpected error occurred: ${e.toString()}");
//     }
//   }
//
//   // Method to show error messages
//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Method to show success messages
//   void _showSuccessDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Action Successful'), // Changed title to be more generic
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade700!, Colors.teal.shade600!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // **AppBar Section**
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     const SizedBox(width: 10),
//                     const Text(
//                       "Seller Signup",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // **Profile Picture**
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white,
//                     backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
//                     child: _profileImage == null
//                         ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
//                         : null,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // **Form Fields**
//                 _buildTextField("Full Name", _fullNameController),
//                 _buildTextField("Username", _usernameController),
//                 _buildTextField("School ID", _schoolIDController),
//                 _buildTextField("School Email", _emailController, keyboardType: TextInputType.emailAddress),
//                 _buildTextField("Password", _passwordController, obscureText: true),
//                 _buildTextField("Confirm Password", _confirmPasswordController, obscureText: true),
//                 _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
//                 _buildTextField("Hostel/Room Number", _hostelController),
//
//                 // **Terms & Conditions Checkbox**
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreeToTerms,
//                       onChanged: (value) {
//                         setState(() {
//                           _agreeToTerms = value!;
//                         });
//                       },
//                     ),
//                     const Expanded(
//                       child: Text(
//                         "I agree to the Terms & Conditions",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // **Signup Button**
//                 ElevatedButton(
//                   onPressed: _agreeToTerms ? _signUp : null,  // Only enable if terms are agreed
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: Text(
//                     "Sign Up",
//                     style: TextStyle(fontSize: 16, color: Colors.green.shade700!),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // **Helper Method for Input Fields**
//   Widget _buildTextField(String label, TextEditingController controller,
//       {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.black54), // Added style for label
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.green.shade700!, width: 2), // Highlight on focus
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.grey, width: 1), // Default border
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerBinding

// Assuming you have a login screen to navigate to after successful signup
import 'login_screen.dart'; // Make sure this path is correct for your LoginScreen

class SellerSignupScreen extends StatefulWidget {
  @override
  _SellerSignupScreenState createState() => _SellerSignupScreenState();
}

class _SellerSignupScreenState extends State<SellerSignupScreen> {
  File? _profileImage;
  final picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _schoolIDController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hostelController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isLoading = false; // Added loading state

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Sign-up method
  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match!");
      return;
    }
    if (!_agreeToTerms) {
      _showError("You must agree to the Terms & Conditions to sign up.");
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true when signup starts
    });

    try {
      User? user;
      String uid;
      String profileImageUrl = "";
      bool newUserCreated = false; // Flag to track if a new user was created

      // Check if an account with this email already exists in Firebase Auth
      try {
        // Attempt to create a new user. If email is already in use, FirebaseAuthException will be caught.
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        user = userCredential.user;
        uid = user!.uid;
        await user.sendEmailVerification(); // Send verification for newly created users
        newUserCreated = true;

      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If email is already in use, try to sign in to get the User object.
          // This assumes an existing user (e.g., a buyer) is trying to upgrade to seller.
          // Note: This path skips email verification unless the user was already verified.
          try {
            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
            user = userCredential.user;
            uid = user!.uid;
            // If they are not verified, prompt them to verify.
            if (user.emailVerified == false) {
              await user.sendEmailVerification();
              SchedulerBinding.instance.addPostFrameCallback((_) { // Use SchedulerBinding to run after build
                _showSuccessDialog("An account with this email already exists and is not verified. A new verification email has been sent. Please verify your email.");
              });
              return; // Exit signup flow for now, user needs to verify existing account
            }

          } on FirebaseAuthException catch (signInError) {
            // If sign-in also fails (e.g., wrong password for existing email)
            _showError(signInError.message ?? "An account with this email exists, but authentication failed. Please check your password or use a different email.");
            return;
          }

        } else if (e.code == 'weak-password') {
          _showError('The password provided is too weak.');
          return;
        } else if (e.code == 'invalid-email') {
          _showError('The email address is not valid.');
          return;
        } else {
          _showError(e.message ?? "An error occurred during account creation.");
          return;
        }
      }

      // If we reach here, 'user' is guaranteed to be non-null and 'uid' is set.

      // Upload profile image (if provided)
      if (_profileImage != null) {
        final uploadTask = _storage.ref('profile_images/$uid.jpg').putFile(_profileImage!);
        profileImageUrl = await (await uploadTask).ref.getDownloadURL();
      }

      // Store or update user information in Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullName': _fullNameController.text,
        'username': _usernameController.text,
        'schoolID': _schoolIDController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'hostel': _hostelController.text,
        'userType': 'seller', // Crucially set/update userType to seller
        'profileImage': profileImageUrl,
        'emailVerified': user?.emailVerified ?? false, // Ensure this is up-to-date
      }, SetOptions(merge: true)); // Use merge: true to update existing fields without overwriting others

      // --- START: CONFIRMATION POP-UP FOR NEW SELLER REGISTRATION ---
      if (newUserCreated) {
        await showDialog(
          context: context,
          barrierDismissible: false, // User must tap OK to dismiss
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Seller Registration Successful!"),
              content: Text(
                  "Welcome, ${_usernameController.text}! Your seller account has been created. "
                      "A verification email has been sent to ${_emailController.text}. "
                      "Please check your inbox (and spam folder) to verify your account before logging in."
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss the dialog
                    // After dismissing, navigate to the LoginScreen
                    // Using pushAndRemoveUntil to clear the stack, preventing going back to signup
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false, // Remove all previous routes
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // This branch handles existing users who are now sellers
        _showSuccessDialog("Your account has been successfully updated to a Seller account!");
        // Navigate to LoginScreen or relevant screen for existing users
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
      // --- END: CONFIRMATION POP-UP ---

    } catch (e) {
      _showError("An unexpected error occurred: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading regardless of success/failure
      });
    }
  }

  // Method to show error messages
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Method to show success messages
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Action Successful'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700!, Colors.teal.shade600!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // **AppBar Section**
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Seller Signup",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // **Profile Picture**
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // **Form Fields**
                _buildTextField("Full Name", _fullNameController),
                _buildTextField("Username", _usernameController),
                _buildTextField("School ID", _schoolIDController),
                _buildTextField("School Email", _emailController, keyboardType: TextInputType.emailAddress),
                _buildTextField("Password", _passwordController, obscureText: true),
                _buildTextField("Confirm Password", _confirmPasswordController, obscureText: true),
                _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
                _buildTextField("Hostel/Room Number", _hostelController),

                // **Terms & Conditions Checkbox**
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I agree to the Terms & Conditions",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // **Signup Button**
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading // Show loading indicator
                      ? const CircularProgressIndicator(color: Colors.green)
                      : Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.green.shade700!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // **Helper Method for Input Fields**
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.green.shade700!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }
}