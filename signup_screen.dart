//
//
// import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Import Home Screen
//
// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController studentIdController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>(); // Form validation key
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Sign Up"),
//         backgroundColor: Color(0xFF004D40),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//
//                 // App Logo
//                 Image.asset('assets/app_logo.png', width: 100, height: 100),
//                 SizedBox(height: 20),
//
//                 // Full Name Field
//                 TextFormField(
//                   controller: fullNameController,
//                   decoration: InputDecoration(
//                     labelText: "Full Name (as per your school ID)",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your full name";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 15),
//
//                 // University Email Field
//                 TextFormField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: "University Email",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your university email";
//                     }
//                     if (!value.contains("@")) {
//                       return "Enter a valid email";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 15),
//
//                 // Student ID Field
//                 TextFormField(
//                   controller: studentIdController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: "Student ID Number",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your student ID number";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 15),
//
//                 // Phone Number Field
//                 TextFormField(
//                   controller: phoneController,
//                   keyboardType: TextInputType.phone,
//                   decoration: InputDecoration(
//                     labelText: "Phone Number",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your phone number";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 15),
//
//                 // Password Field
//                 TextFormField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter a password";
//                     }
//                     if (value.length < 6) {
//                       return "Password must be at least 6 characters";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 30),
//
//                 // Sign Up Button
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF004D40),
//                     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                   ),
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Navigate to Home Screen on success
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => HomeScreen()),
//                       );
//                     }
//                   },
//                   child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
//                 ),
//                 SizedBox(height: 20),
//
//                 // Already have an account? Login
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context); // Go back to login screen
//                   },
//                   child: Text(
//                     "Already have an account? Login",
//                     style: TextStyle(color: Colors.blue, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import Home Screen

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Form validation key

  bool _isLoading = false; // Loading state for the button

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to register user
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password using Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // After successful registration, get the user ID (UID)
        String uid = userCredential.user!.uid;

        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': fullNameController.text,
          'email': emailController.text,
          'studentId': studentIdController.text,
          'phone': phoneController.text,
          'userType': 'buyer', // Default user type is "buyer"
        });

        // Navigate to Home Screen after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(e.message ?? 'An error occurred during sign-up.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor: Color(0xFF004D40),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Image.asset('assets/app_logo.png', width: 100, height: 100),
                SizedBox(height: 20),

                // Full Name Field
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name (as per your school ID)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your full name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // University Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "University Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your university email";
                    }
                    if (!value.contains("@")) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Student ID Field
                TextFormField(
                  controller: studentIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Student ID Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your student ID number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Phone Number Field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your phone number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // Sign Up Button
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004D40),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: _registerUser,
                  child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 20),

                // Already have an account? Login
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to login screen
                  },
                  child: Text(
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
