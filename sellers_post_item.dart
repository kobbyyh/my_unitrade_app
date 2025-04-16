//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'sellers_dashboard.dart';
// import 'sellers_messages.dart';
// import 'sellers_wallet.dart';
// import  'sellers_settings.dart';
//
// class SellerPostItem extends StatefulWidget {
//   @override
//   _SellerPostItemState createState() => _SellerPostItemState();
// }
//
// class _SellerPostItemState extends State<SellerPostItem> {
//   final _formKey = GlobalKey<FormState>();
//   String? selectedCategory;
//   bool isFixed = true;
//   File? _image;
//   final picker = ImagePicker();
//
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController paymentDetailsController = TextEditingController();
//
//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   void _publish() {
//     if (_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Listing Published')),
//       );
//     }
//   }
//
//   void _cancel() {
//     Navigator.pop(context);
//   }
//
//   int _selectedIndex = 0;
//
//   final List<Widget> _pages = [
//     Center(child: Text("Home", style: TextStyle(fontSize: 22))),
//     Center(child: Text("Messages", style: TextStyle(fontSize: 22))),
//     Center(child: Text("Settings", style: TextStyle(fontSize: 22))),
//     Center(child: Text("Wallet", style: TextStyle(fontSize: 22))),
//   ];
//
//   // void _onItemTapped(int index) {
//   //   setState(() => _selectedIndex = index);
//   // }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     // Navigate to the correct screen based on the index
//     switch (index) {
//       case 0: // Home
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellerDashboard()), // Link to sellers_dashboard.dart
//         );
//         break;
//       case 1: // Messages
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SellersMessages()), // Link to sellers_messages.dart
//         );
//         break;
//       case 2: // Settings
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SellersSettings()), // Link to sellers_settings.dart
//         );
//         break;
//       case 3: // Wallet
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SellersWallet()), // Link to sellers_wallet.dart
//         );
//         break;
//     }
//   }
//
//
//   void _navigateToPostScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SellerPostItem()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Post New Item"),
//         backgroundColor: Color(0xFF004D40),
//         automaticallyImplyLeading: false,
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight * 1.2),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Title", style: TextStyle(fontSize: 16)),
//                     TextFormField(
//                       controller: titleController,
//                       decoration: InputDecoration(border: OutlineInputBorder()),
//                       validator: (value) => value!.isEmpty ? 'Enter item title' : null,
//                     ),
//                     SizedBox(height: 16),
//                     Text("Category", style: TextStyle(fontSize: 16)),
//                     DropdownButtonFormField<String>(
//                       value: selectedCategory,
//                       items: [
//                         'Food & Beverages',
//                         'Clothing',
//                         'Accessories',
//                         'Gadgets & Electronics',
//                         'Personal Care & Beauty',
//                         'Books & Stationery',
//                       ]
//                           .map((category) => DropdownMenuItem(
//                           value: category, child: Text(category)))
//                           .toList(),
//                       onChanged: (value) => setState(() => selectedCategory = value),
//                       validator: (value) => value == null ? 'Select a category' : null,
//                     ),
//                     SizedBox(height: 16),
//                     Text("Price", style: TextStyle(fontSize: 16)),
//                     TextFormField(
//                       controller: priceController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(border: OutlineInputBorder()),
//                       validator: (value) => value!.isEmpty ? 'Enter price' : null,
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ChoiceChip(
//                           label: Text("Fixed", style: TextStyle(color: isFixed ? Colors.white : Colors.black)),
//                           selected: isFixed,
//                           onSelected: (selected) => setState(() => isFixed = true),
//                           selectedColor: Color(0xFF004D40),
//                           backgroundColor: Colors.grey[300],
//                         ),
//                         ChoiceChip(
//                           label: Text("Negotiable", style: TextStyle(color: !isFixed ? Colors.white : Colors.black)),
//                           selected: !isFixed,
//                           onSelected: (selected) => setState(() => isFixed = false),
//                           selectedColor: Color(0xFF004D40),
//                           backgroundColor: Colors.grey[300],
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     Text("Product Description (Optional)", style: TextStyle(fontSize: 16)),
//                     TextFormField(
//                       controller: descriptionController,
//                       maxLines: 3,
//                       decoration: InputDecoration(border: OutlineInputBorder()),
//                     ),
//                     SizedBox(height: 16),
//                     Text("Upload Image", style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 10),
//                     _image != null ? Image.file(_image!, height: 100) : Text("No image selected."),
//                     TextButton.icon(
//                       icon: Icon(Icons.image),
//                       label: Text("Choose Image"),
//                       onPressed: _pickImage,
//                     ),
//                     SizedBox(height: 16),
//                     Text("Location Details", style: TextStyle(fontSize: 16)),
//                     TextFormField(
//                       controller: locationController,
//                       decoration: InputDecoration(border: OutlineInputBorder()),
//                       validator: (value) => value!.isEmpty ? 'Enter location' : null,
//                     ),
//                     SizedBox(height: 16),
//                     Text("Payment Details", style: TextStyle(fontSize: 16)),
//                     TextFormField(
//                       controller: paymentDetailsController,
//                       decoration: InputDecoration(border: OutlineInputBorder()),
//                       validator: (value) => value!.isEmpty ? 'Enter payment info' : null,
//                     ),
//                     SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: _cancel,
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
//                           child: Text("Cancel", style: TextStyle(color: Colors.black)),
//                         ),
//                         ElevatedButton(
//                           onPressed: _publish,
//                           style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF004D40)),
//                           child: Text("Publish", style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.blueGrey,
//         shape: CircularNotchedRectangle(),
//         notchMargin: 10,
//         child: SizedBox(
//           height: 60,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               _buildNavIcon(Icons.home, 0),
//               _buildNavIcon(Icons.message, 1),
//               SizedBox(width: 40), // Space for the FAB
//               _buildNavIcon(Icons.settings, 2),
//               _buildNavIcon(Icons.account_balance_wallet, 3),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToPostScreen,
//         backgroundColor: Colors.blueGrey,
//         child: Icon(Icons.add, size: 30),
//         shape: CircleBorder(),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Widget _buildNavIcon(IconData icon, int index) {
//     return IconButton(
//       icon: Icon(
//         icon,
//         color: _selectedIndex == index ? Colors.white : Colors.white70,
//         size: 30,
//       ),
//       onPressed: () => _onItemTapped(index),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
  final picker = ImagePicker();
  File? _image;

  String? selectedCategory;
  bool isFixed = true;
  bool isUploading = false;

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final paymentDetailsController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _uploadAndPublish() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_image == null ? "Please select an image." : "Please complete the form."),
      ));
      return;
    }

    setState(() => isUploading = true);
    final itemId = Uuid().v4();
    final storageRef = FirebaseStorage.instance.ref().child('item_images/$itemId.jpg');

    try {
      // Upload image to Firebase Storage
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;

      // Get the image URL after successful upload
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Save the item data along with image URL to Firestore
      await FirebaseFirestore.instance.collection('items').doc(itemId).set({
        'title': titleController.text.trim(),
        'category': selectedCategory,
        'price': double.parse(priceController.text.trim()),
        'isFixed': isFixed,
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrl,  // Save the image URL here
        'location': locationController.text.trim(),
        'paymentDetails': paymentDetailsController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item Published')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _cancel() => Navigator.pop(context);

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
        Navigator.push(context, MaterialPageRoute(builder: (_) => SellersMessages()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SellersSettings()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SellersWallet()));
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 This keeps the FAB fixed when keyboard appears
      appBar: AppBar(
        title: Text("Post New Item"),
        backgroundColor: Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),
      body: isUploading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight * 1.2),
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
                    ),

                    _buildInputLabel("Price"),
                    _buildTextField(priceController, "Enter price", isNumber: true),

                    SizedBox(height: 10),
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
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),

                    _buildInputLabel("Upload Image"),
                    SizedBox(height: 10),
                    _image != null
                        ? Image.file(_image!, height: 100)
                        : Text("No image selected."),
                    TextButton.icon(
                      icon: Icon(Icons.image),
                      label: Text("Choose Image"),
                      onPressed: _pickImage,
                    ),

                    _buildInputLabel("Location Details"),
                    _buildTextField(locationController, "Enter location"),

                    _buildInputLabel("Payment Details"),
                    _buildTextField(paymentDetailsController, "Enter payment info"),

                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _cancel,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: Text("Cancel", style: TextStyle(color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: _uploadAndPublish,
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF004D40)),
                          child: Text("Publish", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.home, 0),
              _buildNavIcon(Icons.message, 1),
              SizedBox(width: 40), // Space for FAB
              _buildNavIcon(Icons.settings, 2),
              _buildNavIcon(Icons.account_balance_wallet, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostScreen,
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add, size: 30),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 4),
    child: Text(label, style: TextStyle(fontSize: 16)),
  );

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(border: OutlineInputBorder(), hintText: hint),
      validator: (value) => value!.isEmpty ? hint : null,
    );
  }

  Widget _buildPriceTypeChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Color(0xFF004D40),
      backgroundColor: Colors.grey[300],
    );
  }
}
