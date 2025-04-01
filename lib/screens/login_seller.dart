import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the home screen

class LoginSellerScreen extends StatefulWidget {
  @override
  _LoginSellerScreenState createState() => _LoginSellerScreenState();
}

class _LoginSellerScreenState extends State<LoginSellerScreen> {
  final TextEditingController sellerIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

                // // University Email Input
                // TextFormField(
                //   controller: sellerIdController,
                //   decoration: InputDecoration(
                //     labelText: "University Email",
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return "Please enter your University Email";
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(height: 20),


                TextFormField(
                  controller: sellerIdController,
                  decoration: InputDecoration(
                    labelText: "Seller ID",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your Seller ID";
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

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Forgot password functionality (To be implemented)
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004D40),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Navigate to Home Screen (Later change this to Seller Dashboard)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  },
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
