


import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hostelController = TextEditingController();

  bool _agreeToTerms = false;

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

    try {
      // Create a new user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If the user is created successfully, upload the profile image (if provided)
      String profileImageUrl = "";
      if (_profileImage != null) {
        final uploadTask = await _storage.ref('profile_images/${userCredential.user!.uid}.jpg').putFile(_profileImage!);
        profileImageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Store user information in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text,
        'username': _usernameController.text,
        'schoolID': _schoolIDController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'hostel': _hostelController.text,
        'userType': 'seller',
        'profileImage': profileImageUrl,  // Store the image URL if available
      });

      // After successful sign up, navigate to another screen (e.g., Seller Dashboard)
      Navigator.pushReplacementNamed(context, '/sellerDashboard');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "An error occurred");
    }
  }

  // Method to show error messages
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
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
            colors: [Colors.green.shade700, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // **AppBar Section**
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Seller Signup",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // **Profile Picture**
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                SizedBox(height: 20),

                // **Form Fields**
                _buildTextField("Full Name", _fullNameController),
                _buildTextField("Username", _usernameController),
                _buildTextField("School ID", _schoolIDController),
                _buildTextField("School Email", _emailController, keyboardType: TextInputType.emailAddress),
                _buildTextField("OTP Code", _otpController),
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
                    Expanded(
                      child: Text(
                        "I agree to the Terms & Conditions",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // **Signup Button**
                ElevatedButton(
                  onPressed: _agreeToTerms ? _signUp : null,  // Only enable if terms are agreed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.green.shade700),
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
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}


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
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _hostelController = TextEditingController();
//
//   bool _agreeToTerms = false;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _sendOtpToEmail() async {
//     final email = _emailController.text.trim();
//     final schoolID = _schoolIDController.text.trim();
//
//     if (email.isEmpty || schoolID.isEmpty) {
//       _showError("Please enter both email and school ID.");
//       return;
//     }
//
//     try {
//       final doc = await _firestore.collection('universities').doc(schoolID).get();
//
//       if (!doc.exists) {
//         _showError("Invalid School ID.");
//         return;
//       }
//
//       final emailDomain = doc['emailDomain'];
//       if (!email.endsWith(emailDomain)) {
//         _showError("Email does not match the school's domain: $emailDomain");
//         return;
//       }
//
//       await _auth.sendPasswordResetEmail(email: email);
//       _showSuccess("OTP sent to email successfully.");
//
//     } catch (e) {
//       _showError("Failed to send OTP to email. Please check the School ID or try again.");
//     }
//   }
//
//   Future<void> _signUp() async {
//     if (_passwordController.text != _confirmPasswordController.text) {
//       _showError("Passwords do not match!");
//       return;
//     }
//
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//
//       String profileImageUrl = "";
//       if (_profileImage != null) {
//         final uploadTask = await _storage.ref('profile_images/${userCredential.user!.uid}.jpg').putFile(_profileImage!);
//         profileImageUrl = await uploadTask.ref.getDownloadURL();
//       }
//
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'fullName': _fullNameController.text,
//         'username': _usernameController.text,
//         'schoolID': _schoolIDController.text,
//         'email': _emailController.text,
//         'phone': _phoneController.text,
//         'hostel': _hostelController.text,
//         'userType': 'seller',
//         'profileImage': profileImageUrl,
//       });
//
//       _showSuccessDialog();
//
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? "An error occurred");
//     }
//   }
//
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Success'),
//         content: Text('You have signed up successfully!'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               Navigator.pushReplacementNamed(context, '/sellerDashboard');
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Error'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSuccess(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Success'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: Text('OK'),
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
//             colors: [Colors.green.shade700, Colors.teal.shade600],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       "Seller Signup",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white,
//                     backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
//                     child: _profileImage == null
//                         ? Icon(Icons.camera_alt, size: 40, color: Colors.grey)
//                         : null,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 _buildTextField("Full Name", _fullNameController),
//                 _buildTextField("Username", _usernameController),
//                 _buildTextField("School ID", _schoolIDController),
//                 _buildTextField("School Email", _emailController, keyboardType: TextInputType.emailAddress),
//                 ElevatedButton(
//                   onPressed: _sendOtpToEmail,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: Text(
//                     "Generate Code",
//                     style: TextStyle(fontSize: 16, color: Colors.green.shade700),
//                   ),
//                 ),
//                 _buildTextField("OTP Code", _otpController),
//                 _buildTextField("Password", _passwordController, obscureText: true),
//                 _buildTextField("Confirm Password", _confirmPasswordController, obscureText: true),
//                 _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
//                 _buildTextField("Hostel/Room Number", _hostelController),
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
//                     Expanded(
//                       child: Text(
//                         "I agree to the Terms & Conditions",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _agreeToTerms ? _signUp : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: Text(
//                     "Sign Up",
//                     style: TextStyle(fontSize: 16, color: Colors.green.shade700),
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
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }
// }
