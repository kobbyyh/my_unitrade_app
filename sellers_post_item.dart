

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Ensure these imports are correct based on your file structure
import 'sellers_dashboard.dart';
import 'sellers_messages.dart';
import 'sellers_wallet.dart';
import 'sellers_settings.dart';

class SellerPostItem extends StatefulWidget {
  @override
  _SellerPostItemState createState() => _SellerPostItemState();
}

class _SellerPostItemState extends State<SellerPostItem> {
  final _formKey = GlobalKey<FormState>();

  String? selectedCategory;
  bool isFixed = true;
  bool isUploading = false;

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final paymentDetailsController = TextEditingController();

  Future<void> _uploadAndPublish() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please complete the form."),
      ));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You must be logged in to post an item.'),
      ));
      return;
    }

    setState(() => isUploading = true);
    final itemId = Uuid().v4();

    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).set({
        'title': titleController.text.trim(),
        'category': selectedCategory,
        'price': double.parse(priceController.text.trim()),
        'isFixed': isFixed,
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'paymentMethod': paymentDetailsController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'sellerId': user.uid,
        'sellerEmail': user.email,
        'isAvailable': true,
        'isSold': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item Published')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellerDashboard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Publish failed: $e')));
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _cancel() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    locationController.clear();
    paymentDetailsController.clear();
    setState(() {
      selectedCategory = null;
      isFixed = true;
    });
    Navigator.pop(context);
  }

  void _navigateToPostScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SellerPostItem()));
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellerDashboard()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellersMessages()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellersSettings()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SellersWallet()));
        break;
    }
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.white70, size: 30),
      onPressed: () => _onItemTapped(index),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    paymentDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the height of the keyboard if it's visible
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Define the fixed height of your BottomAppBar
    const double bottomAppBarHeight = 60.0; // Based on your SizedBox height
    // Define the default FAB diameter (standard is 56.0)
    const double fabDiameter = 56.0;
    // Define the notch margin
    const double fabNotchMargin = 10.0;

    // Calculate the total height of the fixed bottom navigation area + space for FAB
    // This is the space that needs to be 'padded out' at the bottom of the scrollable content.
    // It's the bottom app bar + half the FAB (which sits within the notch) + the notch margin.
    // Plus a little extra buffer if needed to ensure the form buttons are not too close.
    final double fixedBottomAreaHeight = bottomAppBarHeight + (fabDiameter / 2) + fabNotchMargin + 10.0; // Added 10.0 buffer

    return Scaffold(
      // CRITICAL: Set resizeToAvoidBottomInset to false.
      // This tells the Scaffold to NOT resize its body when the keyboard appears.
      // This ensures the bottomNavigationBar and floatingActionButton remain fixed.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Post New Item"),
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),
      body: isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20.0, // Left padding
          20.0, // Top padding
          20.0, // Right padding
          // Dynamic bottom padding: keyboard height + the height of our fixed bottom bar/FAB area
          keyboardHeight + fixedBottomAreaHeight,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel("Title"),
              _buildTextField(titleController, "Enter item title"),

              _buildInputLabel("Category"),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: [
                  'Food & Beverages',
                  'Clothing',
                  'Accessories',
                  'Gadgets & Electronics',
                  'Personal Care & Beauty',
                  'Books & Stationery',
                ]
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) => value == null ? 'Select a category' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select a category",
                ),
              ),

              _buildInputLabel("Price"),
              _buildTextField(priceController, "Enter price", isNumber: true),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPriceTypeChip("Fixed", isFixed, () => setState(() => isFixed = true)),
                  _buildPriceTypeChip("Negotiable", !isFixed, () => setState(() => isFixed = false)),
                ],
              ),

              _buildInputLabel("Product Description (Optional)"),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Describe your item (e.g., condition, features)",
                ),
              ),

              _buildInputLabel("Location Details"),
              _buildTextField(locationController, "Enter pickup location (e.g., Hostel Block, Room Number)"),

              _buildInputLabel("Payment Method"),
              _buildTextField(paymentDetailsController, "e.g., Momo number, Bank Account details, Cash", isRequired: true),

              const SizedBox(height: 24), // Space before buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _cancel,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: _uploadAndPublish,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40)),
                    child: const Text("Publish", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // --- FAB and BottomAppBar are defined here, letting Scaffold manage their fixed position ---
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        shape: const CircularNotchedRectangle(),
        notchMargin: fabNotchMargin, // Use constant here for consistency
        child: SizedBox(
          height: bottomAppBarHeight, // Use constant here for consistency
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.home, 0),
              _buildNavIcon(Icons.message, 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavIcon(Icons.settings, 2),
              _buildNavIcon(Icons.account_balance_wallet, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostScreen,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, size: 30),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- Helper Widgets (No changes needed here) ---
  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 4),
    child: Text(label, style: const TextStyle(fontSize: 16)),
  );

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hint,
        errorMaxLines: 2,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (isNumber) {
          if (value == null || value.isEmpty) {
            return 'Please enter a price';
          }
          if (double.tryParse(value) == null) {
            return 'Enter a valid number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPriceTypeChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF004D40),
      backgroundColor: Colors.grey[300],
    );
  }
}