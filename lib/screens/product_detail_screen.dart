
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:UniTrade/screens/chat_screen.dart'; // <--- IMPORTANT: Changed to your ChatScreen import
// import 'package:provider/provider';
import 'package:provider/provider.dart'; // Import provider

import 'package:UniTrade/models/cart_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({Key? key, required this.productData}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String sellerName = "Loading..."; // Initial state
  String sellerContact = "Loading...";
  String sellerLocation = "Loading...";
  String sellerProfileImageUrl = ""; // To store seller's profile image for chat

  @override
  void initState() {
    super.initState();
    _fetchSellerDetails();
  }

  // In _ProductDetailScreenState class

  // String sellerProfileImageUrl = ""; // Keep the declaration at the top

  Future<void> _fetchSellerDetails() async {
    try {
      String? sellerId = widget.productData['sellerId'];
      print('ProductDetailScreen: Fetching seller details for ID: $sellerId');

      if (sellerId != null && sellerId.isNotEmpty) {
        DocumentSnapshot sellerDoc = await _firestore.collection('users').doc(sellerId).get();
        if (sellerDoc.exists) {
          setState(() {
            sellerName = sellerDoc['fullName'] ?? sellerDoc['username'] ?? "N/A";
            sellerContact = sellerDoc['phone'] ?? "N/A";
            sellerLocation = sellerDoc['hostel'] ?? "N/A";
            // sellerProfileImageUrl = sellerDoc['profileImageUrl'] ?? ''; // <-- COMMENT OUT OR REMOVE THIS
          });
          print('ProductDetailScreen: Seller details fetched: $sellerName');
        } else {
          setState(() {
            sellerName = "Seller Not Found";
            sellerContact = "N/A";
            sellerLocation = "N/A";
            // sellerProfileImageUrl = ""; // <-- COMMENT OUT OR REMOVE THIS
          });
          print('ProductDetailScreen: Seller document not found for ID: $sellerId');
        }
      } else {
        setState(() {
          sellerName = "Unknown Seller";
          sellerContact = "N/A";
          sellerLocation = "N/A";
          // sellerProfileImageUrl = ""; // <-- COMMENT OUT OR REMOVE THIS
        });
        print('ProductDetailScreen: Seller ID is null or empty.');
      }
    } catch (e) {
      print("ProductDetailScreen: Error fetching seller details: $e");
      setState(() {
        sellerName = "Error";
        sellerContact = "Error";
        sellerLocation = "Error";
        // sellerProfileImageUrl = ""; // <-- COMMENT OUT OR REMOVE THIS
      });
    }
  }

  // Future<void> _fetchSellerDetails() async {
  //   try {
  //     String? sellerId = widget.productData['sellerId'];
  //     print('ProductDetailScreen: Fetching seller details for ID: $sellerId');
  //
  //     if (sellerId != null && sellerId.isNotEmpty) {
  //       DocumentSnapshot sellerDoc = await _firestore.collection('users').doc(sellerId).get();
  //       if (sellerDoc.exists) {
  //         setState(() {
  //           sellerName = sellerDoc['fullName'] ?? sellerDoc['username'] ?? "N/A";
  //           sellerContact = sellerDoc['phone'] ?? "N/A";
  //           sellerLocation = sellerDoc['hostel'] ?? "N/A";
  //           sellerProfileImageUrl = sellerDoc['profileImageUrl'] ?? ''; // Fetch profile image URL
  //         });
  //         print('ProductDetailScreen: Seller details fetched: $sellerName');
  //       } else {
  //         setState(() {
  //           sellerName = "Seller Not Found";
  //           sellerContact = "N/A";
  //           sellerLocation = "N/A";
  //           sellerProfileImageUrl = "";
  //         });
  //         print('ProductDetailScreen: Seller document not found for ID: $sellerId');
  //       }
  //     } else {
  //       setState(() {
  //         sellerName = "Unknown Seller";
  //         sellerContact = "N/A";
  //         sellerLocation = "N/A";
  //         sellerProfileImageUrl = "";
  //       });
  //       print('ProductDetailScreen: Seller ID is null or empty.');
  //     }
  //   } catch (e) {
  //     print("ProductDetailScreen: Error fetching seller details: $e");
  //     setState(() {
  //       sellerName = "Error";
  //       sellerContact = "Error";
  //       sellerLocation = "Error";
  //       sellerProfileImageUrl = "";
  //     });
  //   }
  // }

  // Helper function to generate a consistent chat room ID
  String _getChatRoomId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort(); // Sorts to ensure consistent order (e.g., "id1_id2" not "id2_id1")
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.productData['imageUrl'] ?? 'https://via.placeholder.com/300';
    final String productName = widget.productData['name'] ?? 'Product Name';
    final double price = (widget.productData['price'] ?? 0.0).toDouble();
    final String paymentMethod = widget.productData['paymentMethod'] ?? 'Kindly contact the seller';
    final String description = widget.productData['description'] ?? 'No description available.';
    final String? sellerId = widget.productData['sellerId'] as String?;
    final String? itemId = widget.productData['itemId'] as String?; // Product's own ID

    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
        title: Text(productName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "GHS ${price.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 10),

                  // Product Details
                  _buildDetailRow(context, "Seller", sellerName),
                  _buildDetailRow(context, "Location", sellerLocation),
                  _buildDetailRow(context, "Contact Number", sellerContact),
                  _buildDetailRow(context, "Payment Method", paymentMethod),
                  const SizedBox(height: 10),

                  if (description.isNotEmpty && description != 'No description available.') ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Description:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (itemId == null || sellerId == null || sellerName == "Loading..." || sellerName == "Unknown Seller" || sellerName == "Error") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please wait for seller info to load or check product data.")),
                              );
                              return;
                            }

                            Provider.of<CartModel>(context, listen: false).addItem({
                              'itemId': itemId,
                              'name': productName,
                              'price': price,
                              'imageUrl': imageUrl,
                              'sellerId': sellerId,
                              'sellerName': sellerName,
                              'paymentMethod': paymentMethod,
                              'description': description,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$productName added to cart!")),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          label: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please log in to chat.")),
                              );
                              return;
                            }
                            if (sellerId == null || sellerId.isEmpty || sellerName == "Loading..." || sellerName == "Error") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Seller information not available to start chat.")),
                              );
                              return;
                            }

                            // Generate chat room ID
                            String chatRoomId = _getChatRoomId(currentUser.uid, sellerId);

                            // Navigate to ChatScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen( // Your ChatScreen class
                                  chatRoomId: chatRoomId,
                                  otherUserId: sellerId,
                                  otherUserName: sellerName,
                                  otherUserImage: sellerProfileImageUrl.isNotEmpty
                                      ? sellerProfileImageUrl
                                      : 'assets/default_profile.png', // Use a default image if none
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat, color: Colors.white),
                          label: const Text("Chat Seller", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Text(
              "$label:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}



