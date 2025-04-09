//
//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'home_screen.dart'; // Import the home screen
// import 'login_screen.dart'; // For redirecting to Buyer login
// import 'forgot_password.dart';
// import 'sellers_dashboard.dart';
//
// class LoginSellerScreen extends StatefulWidget {
//   @override
//   _LoginSellerScreenState createState() => _LoginSellerScreenState();
// }
//
// class _LoginSellerScreenState extends State<LoginSellerScreen> {
//   final TextEditingController identifierController = TextEditingController(); // Used for schoolID, email, or username
//   final TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   // Firebase instances
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         // Query Firestore for the user document based on schoolID, email, or username
//         QuerySnapshot snapshot = await _firestore.collection('users')
//             .where('schoolID', isEqualTo: identifierController.text)
//             .get();
//
//         // Also check for email or username (whichever is entered)
//         if (snapshot.docs.isEmpty) {
//           snapshot = await _firestore.collection('users')
//               .where('email', isEqualTo: identifierController.text)
//               .get();
//         }
//
//         if (snapshot.docs.isEmpty) {
//           snapshot = await _firestore.collection('users')
//               .where('username', isEqualTo: identifierController.text)
//               .get();
//         }
//
//         if (snapshot.docs.isNotEmpty) {
//           // The user exists, so now check the password
//           var userDoc = snapshot.docs.first;
//           String userEmail = userDoc['email'];
//           String password = passwordController.text;
//
//           // Authenticate using Firebase Auth
//           UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//             email: userEmail,
//             password: password,
//           );
//
//           // On success, navigate to HomeScreen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()),
//           );
//         } else {
//           // Handle error: User not found
//           _showError("User not found");
//         }
//       } catch (e) {
//         _showError("Error: $e");
//       }
//     }
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF004D40),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // App Logo
//                 Image.asset('assets/app_logo.png', width: 100, height: 100),
//                 SizedBox(height: 20),
//
//                 TextFormField(
//                   controller: identifierController,
//                   decoration: InputDecoration(
//                     labelText: "School ID / Email / Username",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your School ID, Email, or Username";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),
//
//                 // Password Input
//                 TextFormField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your password";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 15),
//
//                 // Forgot Password (left) & Login as Buyer (right)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => LoginScreen()),
//                         );
//                       },
//                       child: Text(
//                         "Login as Buyer",
//                         style: TextStyle(color: Colors.blue, fontSize: 16),
//                       ),
//                     ),
//
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
//                         );
//                       },
//
//                       child: Text(
//                         "Forgot Password?",
//                         style: TextStyle(color: Colors.blue, fontSize: 16),
//                       ),
//                     ),
//
//                   ],
//                 ),
//                 SizedBox(height: 30),
//
//                 // Login Button
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF004D40),
//                     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                   ),
//                   onPressed: _login,
//                   child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart'; // Import the buyer's home screen
import 'login_screen.dart'; // For redirecting to Buyer login
import 'forgot_password.dart';
import 'sellers_dashboard.dart'; // Import the seller dashboard screen

class LoginSellerScreen extends StatefulWidget {
  @override
  _LoginSellerScreenState createState() => _LoginSellerScreenState();
}

class _LoginSellerScreenState extends State<LoginSellerScreen> {
  final TextEditingController identifierController = TextEditingController(); // Used for schoolID, email, or username
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Query Firestore for the user document based on schoolID, email, or username
        QuerySnapshot snapshot = await _firestore.collection('users')
            .where('schoolID', isEqualTo: identifierController.text)
            .get();

        // Also check for email or username (whichever is entered)
        if (snapshot.docs.isEmpty) {
          snapshot = await _firestore.collection('users')
              .where('email', isEqualTo: identifierController.text)
              .get();
        }

        if (snapshot.docs.isEmpty) {
          snapshot = await _firestore.collection('users')
              .where('username', isEqualTo: identifierController.text)
              .get();
        }

        if (snapshot.docs.isNotEmpty) {
          // The user exists, so now check the password
          var userDoc = snapshot.docs.first;
          String userEmail = userDoc['email'];
          String password = passwordController.text;

          // Authenticate using Firebase Auth
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: userEmail,
            password: password,
          );

          // Check if the 'userType' field exists in the document
          if (userDoc.exists && userDoc.data() != null && userDoc['userType'] != null) {
            String userType = userDoc['userType'];
            print('User Type: $userType');  // Debugging log for userType

            // On success, navigate to the appropriate screen based on 'userType'
            if (userType == 'seller') {
              // If the user is a seller, navigate to the Seller Dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SellerDashboard()),
              );
            } else {
              // If the user is a buyer, navigate to the HomeScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          } else {
            // Handle error: 'userType' field is missing or user not found
            _showError("'userType' field missing or user not found");
          }
        } else {
          // Handle error: User not found
          _showError("User not found");
        }
      } catch (e) {
        // Handle any errors during authentication
        _showError("Error: $e");
      }
    }
  }

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
      appBar: AppBar(
        backgroundColor: Color(0xFF004D40),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Image.asset('assets/app_logo.png', width: 100, height: 100),
                SizedBox(height: 20),

                TextFormField(
                  controller: identifierController,
                  decoration: InputDecoration(
                    labelText: "School ID / Email / Username",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your School ID, Email, or Username";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Forgot Password (left) & Login as Buyer (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        "Login as Buyer",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },

                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004D40),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: _login,
                  child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
