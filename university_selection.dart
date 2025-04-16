
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

class UniversitySelection extends StatefulWidget {
  @override
  _UniversitySelectionState createState() => _UniversitySelectionState();
}

class _UniversitySelectionState extends State<UniversitySelection> {
  String? selectedUniversity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> universities = [];
  bool isLoading = true;
  String? errorMessage;

  // Fetch universities from Firestore with timeout and error handling
  Future<void> fetchUniversities() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('universities')
          .get()
          .timeout(Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        throw Exception('No universities found');
      }

      setState(() {
        universities = snapshot.docs.map((doc) => doc['name'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load universities. Please check your internet connection.';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUniversities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004D40),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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

                // Dropdown, loading, or error UI
                if (isLoading) ...[
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading universities..."),
                ] else if (errorMessage != null) ...[
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 10),
                  Text(errorMessage!, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: fetchUniversities,
                    child: Text("Retry"),
                  ),
                ] else ...[
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
                ],

                SizedBox(height: 20),

                // Login Link
                GestureDetector(
                  onTap: () {
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

                // Next Button (enabled only if university is selected)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004D40),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: selectedUniversity == null
                      ? null // Disable button if no university is selected
                      : () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        // MaterialPageRoute(builder: (context) => SignupScreen()),
                        MaterialPageRoute(builder: (context) => SignupScreen(selectedUniversity: selectedUniversity!)),

                      );
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
