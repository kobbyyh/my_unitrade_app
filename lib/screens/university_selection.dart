import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart'; // Import the signup screen

class UniversitySelection extends StatefulWidget {
  @override
  _UniversitySelectionState createState() => _UniversitySelectionState();
}

class _UniversitySelectionState extends State<UniversitySelection> {
  final List<String> universities = [
    'University of Ghana',
    'Kwame Nkrumah University of Sci & Tech',
    'University of Cape Coast',
    'Ashesi University',
    'GIMPA',
    'University for Development Studies',
    'University of Education, Winneba',
    'University of Professional Studies, Accra',
    'Central University'
  ];

  String? selectedUniversity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Select Your University"),
        backgroundColor: Color(0xFF004D40), // Teal color
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keeps it centered
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Image.asset('assets/app_logo.png', width: 100, height: 100),
                SizedBox(height: 20),

                Text(
                  "Choose Your University",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Dropdown Button with Validation
                DropdownButtonFormField<String>(
                  value: selectedUniversity,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: universities.map((university) {
                    return DropdownMenuItem(
                      value: university,
                      child: Text(university),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUniversity = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a university";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Login Link
                GestureDetector(
                  onTap: () {
                    // Navigate to Login Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Next Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004D40), // Teal color
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Navigate to Signup Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    }
                  },
                  child: Text("Next", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
