
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>(); // Added for form validation
  File? _profileImage;
  final picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hostelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // For editable email
  final TextEditingController _studentIdController = TextEditingController(); // For editable student ID

  // Using String? for selectedUniversity to allow null initially
  String? _selectedUniversity;
  List<String> _universities = []; // List to store fetched universities
  Map<String, String> _universityDomains = {}; // Map to store universityName: emailDomain

  String? _currentProfileImageUrl; // To hold the existing image URL from Firestore
  bool _isLoading = true; // To show loading state while fetching data
  bool _isSaving = false; // To show loading state while saving changes

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndUniversities();
  }

  // --- New: Fetch Universities and their Email Domains ---
  Future<void> _fetchUniversities() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('universities').get();
      List<String> tempUniversities = [];
      Map<String, String> tempDomains = {};

      for (var doc in querySnapshot.docs) {
        String uniName = doc['name'] as String;
        String emailDomain = doc['emailDomain'] as String;
        tempUniversities.add(uniName);
        tempDomains[uniName] = emailDomain;
      }

      setState(() {
        _universities = tempUniversities;
        _universityDomains = tempDomains;
      });
    } catch (e) {
      print("Error fetching universities: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load universities: ${e.toString()}')),
      );
    }
  }

  // --- New: Fetch User Data and pre-fill fields ---
  Future<void> _fetchUserDataAndUniversities() async {
    setState(() {
      _isLoading = true;
    });

    await _fetchUniversities(); // Fetch universities first

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          _fullNameController.text = userData['fullName'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _hostelController.text = userData['hostel'] ?? '';
          _emailController.text = userData['email'] ?? user.email ?? ''; // Use Firestore email first, then Auth email
          _studentIdController.text = userData['schoolID'] ?? '';
          _selectedUniversity = userData['university'] as String?; // Assuming 'university' field stores the name

          // Check if current user's email matches a university domain
          if (user.email != null) {
            String userDomain = user.email!.split('@').last;
            // Find which university this domain belongs to
            _universityDomains.forEach((uniName, domain) {
              if (domain == userDomain) {
                _selectedUniversity = uniName;
              }
            });
          }

          _currentProfileImageUrl = userData['profileImage'] ?? '';
          if (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty) {
            // No need to set _profileImage directly here, _currentProfileImageUrl will be used
            // in the CircleAvatar.
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        // Clear _currentProfileImageUrl if a new image is picked
        _currentProfileImageUrl = null;
      });
    }
  }

  // --- New: Save Changes Function ---
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      setState(() { _isSaving = false; });
      return;
    }

    try {
      String? newProfileImageUrl = _currentProfileImageUrl;

      // 1. Upload new profile image if selected
      if (_profileImage != null) {
        final uploadTask = _storage.ref('profile_images/${user.uid}.jpg').putFile(_profileImage!);
        final snapshot = await uploadTask;
        newProfileImageUrl = await snapshot.ref.getDownloadURL();
      }

      // 2. Update user data in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'hostel': _hostelController.text.trim(),
        'email': _emailController.text.trim(), // Update email in Firestore
        'schoolID': _studentIdController.text.trim(), // Update student ID
        'university': _selectedUniversity, // Update selected university
        'profileImage': newProfileImageUrl, // Update profile image URL
      });

      // 3. Update email in Firebase Authentication if changed
      if (user.email != _emailController.text.trim()) {
        try {
          await user.verifyBeforeUpdateEmail(_emailController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email change requires verification. Please check your new email for a verification link.')),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This email is already in use by another account.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update email: ${e.message}')),
            );
          }
          // Important: If email update fails, revert the Firestore email to original
          await _firestore.collection('users').doc(user.uid).update({
            'email': user.email, // Revert Firestore email
          });
          setState(() { _isSaving = false; });
          return; // Stop further execution if email update fails
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _hostelController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700!, Colors.teal.shade600!], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form( // Added Form widget for validation
              key: _formKey,
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
                        "Profile Settings",
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
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) // New image selected
                          : (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty
                          ? NetworkImage(_currentProfileImageUrl!) // Existing image from Firestore
                          : null), // Fallback if no image
                      child: (_profileImage == null && (_currentProfileImageUrl == null || _currentProfileImageUrl!.isEmpty))
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // **Profile Fields**
                  _buildTextField("Full Name", _fullNameController, isEditable: true, validator: (value) => value!.isEmpty ? 'Full Name is required' : null),
                  _buildTextField("Phone Number", _phoneController, isEditable: true, keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? 'Phone Number is required' : null),
                  _buildTextField("Hostel/Room Number", _hostelController, isEditable: true, validator: (value) => value!.isEmpty ? 'Hostel/Room Number is required' : null),

                  // University Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: DropdownButtonFormField<String>(
                      value: _selectedUniversity,
                      decoration: const InputDecoration(
                        labelText: "University",
                        filled: true,
                        fillColor: Colors.white,
                        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _universities.map((String uni) {
                        return DropdownMenuItem(
                          value: uni,
                          child: Text(uni),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUniversity = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Please select your university' : null,
                    ),
                  ),

                  // Student ID (Editable)
                  _buildTextField("Student ID", _studentIdController, isEditable: true, validator: (value) => value!.isEmpty ? 'Student ID is required' : null),

                  // School Email (Editable with validation for university domain)
                  _buildTextField("School Email", _emailController, isEditable: true, keyboardType: TextInputType.emailAddress, validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    if (_selectedUniversity != null && _universityDomains.containsKey(_selectedUniversity)) {
                      String? allowedDomain = _universityDomains[_selectedUniversity!];
                      if (allowedDomain != null && !value.endsWith('@$allowedDomain')) {
                        return 'Email must end with @$allowedDomain for ${_selectedUniversity!}';
                      }
                    }
                    return null;
                  }),

                  const SizedBox(height: 20),

                  // **Save Button**
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges, // Disable button while saving
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.green) // Show loading indicator
                        : Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16, color: Colors.green.shade700!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // **Helper Method for Input Fields**
  Widget _buildTextField(String label, TextEditingController controller, {bool isEditable = true, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField( // Changed from TextField to TextFormField for validation
        controller: controller,
        readOnly: !isEditable,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: validator, // Assign the validator
      ),
    );
  }
}