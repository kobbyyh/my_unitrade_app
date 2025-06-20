
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:UniTrade/models/cart_model.dart'; // Correctly imports CartModel and CartItem
// import 'package:UniTrade/screens/wallet_page.dart'; // Ensure this is correctly imported
// import 'package:uuid/uuid.dart'; // Import for generating unique IDs for messages
//
// class CheckoutScreen extends StatefulWidget {
//   final List<CartItem> cartItems; // Pass cart items to the checkout screen
//
//   const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//
//   String? _selectedPaymentMethod;
//   double _userWalletBalance = 0.0;
//   bool _isLoadingWallet = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDataAndWalletBalance();
//   }
//
//   Future<void> _loadUserDataAndWalletBalance() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//         if (userDoc.exists) {
//           final userData = userDoc.data();
//           _fullNameController.text = userData?['fullName'] ?? '';
//           _phoneNumberController.text = userData?['phoneNumber'] ?? '';
//
//           setState(() {
//             _userWalletBalance = (userData?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//             _isLoadingWallet = false;
//           });
//         }
//       } catch (e) {
//         print("Error loading user data or wallet balance: $e");
//         setState(() {
//           _isLoadingWallet = false;
//         });
//       }
//     } else {
//       setState(() {
//         _isLoadingWallet = false;
//       });
//     }
//   }
//
//   Future<void> _placeOrder() async {
//     // 1. Validate Delivery Info using the Form Key
//     if (!_formKey.currentState!.validate()) {
//       _showSnackBar("Please fill in all required delivery details.");
//       return; // Stop if form is not valid
//     }
//
//     // 2. Validate Payment Method
//     if (_selectedPaymentMethod == null) {
//       _showSnackBar("Please select a payment method.");
//       return; // Stop if no payment method is selected
//     }
//
//     // Show loading dialog *before* async operations that might take time
//     _showLoadingDialog("Processing order...");
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       if (mounted) Navigator.of(context).pop(); // Dismiss loading
//       _showSnackBar("You must be logged in to place an order.");
//       return;
//     }
//
//     final String buyerId = user.uid;
//     final String buyerFullName = _fullNameController.text.trim();
//     final String buyerPhoneNumber = _phoneNumberController.text.trim();
//     final String deliveryLocation = _locationController.text.trim();
//
//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     final double totalOrderPrice = cartModel.totalPrice;
//
//     try {
//       String? orderId; // To store the generated order ID
//
//       if (_selectedPaymentMethod == 'Wallet') {
//         if (_userWalletBalance < totalOrderPrice) {
//           if (mounted) Navigator.of(context).pop(); // Dismiss loading
//           _showInsufficientFundsDialog(totalOrderPrice - _userWalletBalance);
//           return;
//         }
//
//         final userWalletRef = FirebaseFirestore.instance.collection('users').doc(buyerId);
//
//         await FirebaseFirestore.instance.runTransaction((transaction) async {
//           final userDoc = await transaction.get(userWalletRef);
//           final currentBalance = (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//
//           if (currentBalance < totalOrderPrice) {
//             throw Exception("Insufficient funds during transaction."); // Re-check
//           }
//
//           transaction.update(userWalletRef, {'walletBalance': currentBalance - totalOrderPrice});
//
//           // Create order document and get its ID
//           orderId = await _createOrderDocument(transaction, buyerId, totalOrderPrice);
//
//           // Update sellers' balances and create seller transaction records
//           await _processSellerPayments(transaction, buyerId, orderId);
//         });
//
//         // --- SUCCESSFUL WALLET PAYMENT & ORDER PLACEMENT ---
//         // Send notifications to sellers AFTER successful transaction logic
//         await _sendOrderNotificationsToSellers(
//             buyerId, buyerFullName, buyerPhoneNumber, deliveryLocation, orderId!, widget.cartItems);
//
//         // Clear cart IMMEDIATELY after successful transaction logic
//         cartModel.clearCart();
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading
//         _showSuccessDialog("Order placed successfully via Wallet! Congrats!", totalOrderPrice);
//       } else if (_selectedPaymentMethod == 'Mobile Money') {
//         // Dismiss loading dialog first as external action is needed
//         if (mounted) Navigator.of(context).pop();
//         _showLoadingDialog("Please complete Mobile Money payment in the external window/app."); // New message
//
//         await Future.delayed(const Duration(seconds: 3)); // Simulate external payment time
//
//         orderId = await _createOrderDocument(null, buyerId, totalOrderPrice);
//         await _processSellerPayments(null, buyerId, orderId); // Sellers also get paid on simulated MoMo success
//
//         // After simulated successful payment and order/seller processing
//         await _sendOrderNotificationsToSellers(
//             buyerId, buyerFullName, buyerPhoneNumber, deliveryLocation, orderId!, widget.cartItems);
//
//         // Clear cart AFTER simulated successful payment and order/seller processing
//         cartModel.clearCart();
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading
//         _showSuccessDialog("Order placed successfully via Mobile Money (pending payment confirmation)! Congrats!", totalOrderPrice);
//       } else if (_selectedPaymentMethod == 'In-Person') {
//         // Dismiss the initial loading dialog
//         if (mounted) Navigator.of(context).pop();
//
//         // Create the order document. No payment processing here, as it's 'In-Person'.
//         // You might want to update item status to 'ordered' or 'reserved' if applicable.
//         orderId = await _createOrderDocument(null, buyerId, totalOrderPrice);
//
//         // Send notifications to sellers for their items in the order
//         await _sendOrderNotificationsToSellers(
//             buyerId, buyerFullName, buyerPhoneNumber, deliveryLocation, orderId!, widget.cartItems);
//
//         // Clear the cart after successfully placing the order
//         cartModel.clearCart();
//
//         // Show the success dialog for in-person payment
//         if (mounted) Navigator.of(context).pop(); // Dismiss any lingering loading dialog
//         _showSuccessDialog("Order placed successfully for In-Person payment! Congrats!", totalOrderPrice);
//       }
//       else {
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading
//         _showSnackBar("Invalid payment method selected.");
//       }
//     } catch (e) {
//       if (mounted) Navigator.of(context).pop(); // Dismiss loading
//       print("Error placing order: $e");
//       _showSnackBar("Error placing order. Please try again.");
//     }
//   }
//
//   // Helper to create the order document in Firestore
//   Future<String> _createOrderDocument(Transaction? transaction, String buyerId, double totalOrderPrice) async {
//     final orderItemsData = widget.cartItems.map((item) => {
//       'itemId': item.itemId,
//       'name': item.name,
//       'price': item.price,
//       'quantity': item.quantity,
//       'imageUrl': item.imageUrl,
//       'sellerId': item.sellerId,
//       'sellerName': item.sellerName,
//     }).toList();
//
//     final orderData = {
//       'buyerId': buyerId,
//       'buyerFullName': _fullNameController.text.trim(),
//       'buyerPhoneNumber': _phoneNumberController.text.trim(),
//       'deliveryLocation': _locationController.text.trim(),
//       'items': orderItemsData,
//       'totalPrice': totalOrderPrice,
//       'paymentMethod': _selectedPaymentMethod,
//       'orderStatus': 'pending', // Initial status
//       'orderDate': FieldValue.serverTimestamp(),
//       'txRef': 'ORDER-${DateTime.now().millisecondsSinceEpoch}-${buyerId}', // Unique reference for the order
//     };
//
//     DocumentReference orderRef;
//     if (transaction != null) {
//       orderRef = FirebaseFirestore.instance.collection('orders').doc();
//       transaction.set(orderRef, orderData);
//     } else {
//       orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);
//     }
//     return orderRef.id;
//   }
//
//   // Helper to process seller payments (add to seller wallet)
//   Future<void> _processSellerPayments(Transaction? transaction, String buyerId, String? orderId) async {
//     Map<String, double> sellerEarnings = {};
//     for (var item in widget.cartItems) {
//       sellerEarnings.update(item.sellerId, (value) => value + (item.price * item.quantity),
//           ifAbsent: () => (item.price * item.quantity));
//     }
//
//     for (var entry in sellerEarnings.entries) {
//       final sellerId = entry.key;
//       final earnings = entry.value;
//
//       final sellerWalletRef = FirebaseFirestore.instance.collection('users').doc(sellerId);
//
//       // This part is for consistency based on our unified model:
//       // Transactions should go into a subcollection under the user.
//       final sellerTransactionsRef = sellerWalletRef.collection('transactions');
//
//       if (transaction != null) {
//         final sellerDoc = await transaction.get(sellerWalletRef);
//         final currentSellerBalance = (sellerDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//         transaction.update(sellerWalletRef, {'walletBalance': currentSellerBalance + earnings});
//
//         // Add transaction to seller's subcollection within the same transaction
//         transaction.set(sellerTransactionsRef.doc(), {
//           'type': 'sale_credit',
//           'amount': earnings,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Credit from sale of items in order by $buyerId',
//           'relatedOrderId': orderId,
//         });
//       } else {
//         // If not in a transaction (e.g., Mobile Money simulation), perform direct write
//         await sellerWalletRef.update({'walletBalance': FieldValue.increment(earnings)});
//         await sellerTransactionsRef.add({
//           'type': 'sale_credit',
//           'amount': earnings,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Credit from sale of items in order by $buyerId',
//           'relatedOrderId': orderId,
//         });
//       }
//     }
//
//     // Record the buyer's transaction for their wallet debit
//     // Only record if payment was via Wallet or Mobile Money (i.e., a direct debit/credit)
//     if (_selectedPaymentMethod == 'Wallet' || _selectedPaymentMethod == 'Mobile Money') {
//       final buyerTransactionsRef = FirebaseFirestore.instance.collection('users').doc(buyerId).collection('transactions');
//       final double totalOrderPrice = Provider.of<CartModel>(context, listen: false).totalPrice; // Re-get total price
//
//       if (transaction != null) {
//         transaction.set(buyerTransactionsRef.doc(), {
//           'type': 'purchase_debit',
//           'amount': -totalOrderPrice, // Negative for debit
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Debit for order placed: $orderId',
//           'relatedOrderId': orderId,
//         });
//       } else {
//         await buyerTransactionsRef.add({
//           'type': 'purchase_debit',
//           'amount': -totalOrderPrice, // Negative for debit
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Debit for order placed: $orderId',
//           'relatedOrderId': orderId,
//         });
//       }
//     }
//   }
//
//   // Helper to send order notifications to sellers
//   Future<void> _sendOrderNotificationsToSellers(
//       String buyerId,
//       String buyerFullName,
//       String buyerPhoneNumber,
//       String deliveryLocation,
//       String orderId,
//       List<CartItem> purchasedItems) async {
//     final Map<String, List<CartItem>> itemsBySeller = {};
//     for (var item in purchasedItems) {
//       itemsBySeller.putIfAbsent(item.sellerId, () => []).add(item);
//     }
//
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final Uuid uuid = Uuid();
//
//     for (var entry in itemsBySeller.entries) {
//       final String sellerId = entry.key;
//       final List<CartItem> sellerSpecificItems = entry.value;
//
//       List<String> participants = [buyerId, sellerId]..sort();
//       String chatId = participants.join('_');
//
//       String sellerName = "Seller"; // Default value
//       try {
//         DocumentSnapshot sellerDoc = await _firestore.collection('users').doc(sellerId).get();
//         if (sellerDoc.exists) {
//           // --- ROBUST FIX FOR SELLER NAME RETRIEVAL ---
//           final Map<String, dynamic>? sellerData = sellerDoc.data() as Map<String, dynamic>?;
//
//           if (sellerData != null) {
//             sellerName = (sellerData['fullName'] as String?) ??
//                 (sellerData['username'] as String?) ??
//                 "Seller";
//           }
//         }
//       } catch (e) {
//         print("Error fetching seller name for notification: $e");
//       }
//
//       String itemDetails = sellerSpecificItems
//           .map((item) => "- ${item.name} (x${item.quantity}) for ₵${(item.price * item.quantity).toStringAsFixed(2)}")
//           .join('\n');
//
//       String messageText =
//           "New Order from $buyerFullName for your items!\n\n"
//           "Order ID: $orderId\n"
//           "Items:\n$itemDetails\n\n"
//           "Buyer Contact: $buyerPhoneNumber\n"
//           "Delivery Location: $deliveryLocation\n\n"
//           "Please arrange pickup/delivery with the buyer.";
//
//       DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
//       await chatRef.set({
//         'participants': participants,
//         'lastMessage': "New order for your items (ID: $orderId)",
//         'lastMessageTimestamp': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       await chatRef.collection('messages').doc(uuid.v4()).set({
//         'senderId': buyerId,
//         'recipientId': sellerId,
//         'text': messageText,
//         'timestamp': FieldValue.serverTimestamp(),
//         'read': false,
//         'type': 'order_notification',
//         'orderId': orderId,
//       });
//
//       print("Sent order notification to seller: $sellerName ($sellerId)");
//     }
//   }
//
//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   void _showLoadingDialog(String message) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Row(
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(width: 20),
//                 Text(message),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   void _showInsufficientFundsDialog(double neededAmount) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Insufficient Funds"),
//             content: Text("Your wallet balance is not enough. You need ₵${neededAmount.toStringAsFixed(2)} more. Do you want to top up your wallet?"),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("Cancel"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 child: const Text("Top Up Wallet"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) =>  WalletScreen()),
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   void _showSuccessDialog(String message, double totalOrderPrice) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Row(
//               children: [
//                 Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
//                 SizedBox(width: 10),
//                 Text("Order Placed!"),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(message),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Total amount: ₵${totalOrderPrice.toStringAsFixed(2)}",
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text("You'll receive a confirmation message shortly. Sellers will be notified!"),
//               ],
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.of(context).pop(); // Go back to CartScreen
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneNumberController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cartModel = Provider.of<CartModel>(context);
//     final double totalOrderPrice = cartModel.totalPrice;
//
//     final bool canUseWallet = _userWalletBalance >= totalOrderPrice;
//     final bool canUseMobile = _userWalletBalance >= totalOrderPrice;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Checkout"),
//         backgroundColor: const Color(0xFF004D40),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section 1: Delivery Information
//             const Text(
//               "1. Delivery Information",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _fullNameController,
//                     decoration: const InputDecoration(
//                       labelText: "Full Name",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your full name.';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _phoneNumberController,
//                     keyboardType: TextInputType.phone,
//                     decoration: const InputDecoration(
//                         labelText: "Phone Number",
//                         border: OutlineInputBorder(),
//                         hintText: "e.g., 0551234567"
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your phone number.';
//                       }
//                       if (value.trim().length < 10) {
//                         return 'Phone number is too short.';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _locationController,
//                     decoration: const InputDecoration(
//                         labelText: "Pickup/Delivery Location (e.g., Hostel Block, Room No.)",
//                         border: OutlineInputBorder(),
//                         hintText: "e.g., Volta Hall, Room 205"
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your pickup/delivery location.';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Section 2: Order Summary
//             const Text(
//               "2. Order Summary",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     ...widget.cartItems.map((item) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(child: Text("${item.name} (x${item.quantity}) from ${item.sellerName}")),
//                           Text("₵${(item.price * item.quantity).toStringAsFixed(2)}"),
//                         ],
//                       ),
//                     )).toList(),
//                     const Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text("Total Price:", style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text("₵${totalOrderPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Section 3: Payment Method
//             const Text(
//               "3. Payment Method",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             _isLoadingWallet
//                 ? const Center(child: CircularProgressIndicator())
//                 : Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     RadioListTile<String>(
//                       title: const Text("In-Person (Pay on Pickup/Delivery)"),
//                       value: 'In-Person',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       },
//                       activeColor: const Color(0xFF004D40),
//                     ),
//
//                     RadioListTile<String>(
//                       title: Text(
//                         "Wallet (Balance: ₵${_userWalletBalance.toStringAsFixed(2)})",
//                         style: TextStyle(
//                           color: canUseWallet ? Colors.black : Colors.grey[600],
//                         ),
//                       ),
//                       value: 'Wallet',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: canUseWallet ? (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       } : null,
//                       activeColor: const Color(0xFF004D40),
//                     ),
//
//                     RadioListTile<String>(
//                       title: Text(
//                         "Mobile Money (MTN, Vodafone, AirtelTigo)",
//                         style: TextStyle(
//                           color: canUseMobile ? Colors.black : Colors.grey[600],
//                         ),
//                       ),
//                       value: 'Mobile Money',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: canUseMobile ? (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       } : null,
//                       activeColor: const Color(0xFF004D40),
//                     )
//
//
//                     // RadioListTile<String>(
//                     //   title: const Text("Mobile Money (MTN, Vodafone, AirtelTigo)"),
//                     //   value: 'Mobile Money',
//                     //   groupValue: _selectedPaymentMethod,
//                     //   onChanged: (String? value) {
//                     //     setState(() {
//                     //       _selectedPaymentMethod = value;
//                     //     });
//                     //   },
//                     //   activeColor: const Color(0xFF004D40),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Final: Place Order Button
//             ElevatedButton(
//               onPressed: _placeOrder,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF004D40),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text(
//                 "Place Order",
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:UniTrade/models/cart_model.dart';
// import 'package:UniTrade/screens/wallet_page.dart';
// import 'package:uuid/uuid.dart';
// import 'package:UniTrade/screens/confirmation_screen.dart'; // Corrected import
// import 'package:UniTrade/screens/home_screen.dart'; // Corrected import
// import 'package:intl/intl.dart'; // Keep this import, run 'flutter pub add intl'
//
// class CheckoutScreen extends StatefulWidget {
//   final List<CartItem> cartItems;
//
//   const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//
//   String? _selectedPaymentMethod = 'In-Person'; // Default to In-Person
//   double _userWalletBalance = 0.0;
//   bool _isLoadingWallet = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDataAndWalletBalance();
//   }
//
//   Future<void> _loadUserDataAndWalletBalance() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//         if (userDoc.exists) {
//           final userData = userDoc.data();
//           _fullNameController.text = userData?['fullName'] ?? '';
//           _phoneNumberController.text = userData?['phoneNumber'] ?? '';
//
//           setState(() {
//             _userWalletBalance = (userData?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//             _isLoadingWallet = false;
//           });
//         }
//       } catch (e) {
//         print("Error loading user data or wallet balance: $e");
//         setState(() {
//           _isLoadingWallet = false;
//         });
//       }
//     } else {
//       setState(() {
//         _isLoadingWallet = false;
//       });
//     }
//   }
//
//   Future<void> _placeOrder() async {
//     // 1. Validate Delivery Info using the Form Key
//     if (!_formKey.currentState!.validate()) {
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//       _showSnackBar("Please fill in all required delivery details.");
//       return;
//     }
//
//     // 2. Validate Payment Method
//     if (_selectedPaymentMethod == null) {
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//       _showSnackBar("Please select a payment method.");
//       return;
//     }
//
//     _showLoadingDialog("Processing order...");
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       if (mounted) Navigator.of(context).pop();
//       _showSnackBar("You must be logged in to place an order.");
//       return;
//     }
//
//     final String buyerId = user.uid;
//     final String buyerFullName = _fullNameController.text.trim();
//     final String buyerPhoneNumber = _phoneNumberController.text.trim();
//     final String deliveryLocation = _locationController.text.trim();
//
//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     final double totalOrderPrice = cartModel.totalPrice;
//
//     try {
//       String? orderId;
//
//       if (_selectedPaymentMethod == 'Wallet') {
//         if (_userWalletBalance < totalOrderPrice) {
//           if (mounted) Navigator.of(context).pop();
//           _showInsufficientFundsDialog(totalOrderPrice - _userWalletBalance);
//           return;
//         }
//
//         final userWalletRef = FirebaseFirestore.instance.collection('users').doc(buyerId);
//
//         await FirebaseFirestore.instance.runTransaction((transaction) async {
//           final userDoc = await transaction.get(userWalletRef);
//           final currentBalance = (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//
//           if (currentBalance < totalOrderPrice) {
//             throw Exception("Insufficient funds during transaction.");
//           }
//
//           transaction.update(userWalletRef, {'walletBalance': currentBalance - totalOrderPrice});
//
//           orderId = await _createOrderDocument(transaction, buyerId, totalOrderPrice);
//           await _processSellerPayments(transaction, buyerId, orderId);
//         });
//
//         await _sendOrderNotificationsToSellers(
//             buyerId, buyerFullName, buyerPhoneNumber, deliveryLocation, orderId!, widget.cartItems);
//         cartModel.clearCart();
//
//       } else if (_selectedPaymentMethod == 'Mobile Money') {
//         if (mounted) Navigator.of(context).pop();
//         _showLoadingDialog("Please complete Mobile Money payment in the external window/app.");
//
//         await Future.delayed(const Duration(seconds: 3));
//
//         orderId = await _createOrderDocument(null, buyerId, totalOrderPrice);
//         await _processSellerPayments(null, buyerId, orderId);
//
//         await _sendOrderNotificationsToSellers(
//             buyerId, buyerFullName, buyerPhoneNumber, deliveryLocation, orderId!, widget.cartItems);
//         cartModel.clearCart();
//
//       } else if (_selectedPaymentMethod == 'In-Person') {
//         if (mounted) Navigator.of(context).pop();
//
//         orderId = await _createOrderDocument(null, buyerId, totalOrderPrice);
//
//         await _sendOrderNotificationsToSellers(
//             buyerId, buyerFullName, buyerPhoneNumber, deliveryLocation, orderId!, widget.cartItems);
//         cartModel.clearCart();
//       }
//       else {
//         if (mounted) Navigator.of(context).pop();
//         _showSnackBar("Invalid payment method selected.");
//         return;
//       }
//
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//
//       // Fetch the order document to get the precise server timestamp
//       DocumentSnapshot orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId!).get();
//
//       // --- START OF MODIFIED TIMESTAMP RETRIEVAL ---
//       Timestamp? orderTimestamp;
//       DateTime orderDateTime;
//
//       if (orderDoc.exists) {
//         // --- MODIFIED LINE: Force cast orderDoc to dynamic to bypass compiler check ---
//         final Map<String, dynamic>? orderData = (orderDoc as dynamic).data();
//         // -------------------------------------------------------------------------
//
//         if (orderData != null && orderData.containsKey('orderDate')) {
//           final dynamic dataValue = orderData['orderDate'];
//           if (dataValue is Timestamp) {
//             orderTimestamp = dataValue;
//             orderDateTime = orderTimestamp.toDate();
//           } else {
//             print("Warning: 'orderDate' is not a Timestamp in Firestore for order ${orderId}. Actual type: ${dataValue.runtimeType}. Falling back to current time.");
//             orderDateTime = DateTime.now(); // Fallback to current time
//           }
//         } else {
//           print("Warning: 'orderDate' field not found in order ${orderId}. Falling back to current time.");
//           orderDateTime = DateTime.now(); // Fallback if field is missing
//         }
//       } else {
//         print("Warning: Order document ${orderId} does not exist. Falling back to current time.");
//         orderDateTime = DateTime.now(); // Fallback if document doesn't exist
//       }
//
//       // if (orderDoc.exists) {
//       //   final Map<String, dynamic>? orderData = orderDoc.data();
//       //   if (orderData != null && orderData.containsKey('orderDate')) {
//       //     final dynamic dataValue = orderData['orderDate'];
//       //     if (dataValue is Timestamp) {
//       //       orderTimestamp = dataValue;
//       //       orderDateTime = orderTimestamp.toDate();
//       //     } else {
//       //       // This case should ideally not happen if FieldValue.serverTimestamp() is used correctly
//       //       print("Warning: 'orderDate' is not a Timestamp in Firestore for order ${orderId}. Actual type: ${dataValue.runtimeType}. Falling back to current time.");
//       //       orderDateTime = DateTime.now(); // Fallback to current time
//       //     }
//       //   } else {
//       //     print("Warning: 'orderDate' field not found in order ${orderId}. Falling back to current time.");
//       //     orderDateTime = DateTime.now(); // Fallback if field is missing
//       //   }
//       // } else {
//       //   print("Warning: Order document ${orderId} does not exist. Falling back to current time.");
//       //   orderDateTime = DateTime.now(); // Fallback if document doesn't exist
//       // }
//       // --- END OF MODIFIED TIMESTAMP RETRIEVAL ---
//
//       if (mounted) {
//         print("DEBUG: Navigating to confirmation screen.");
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ConfirmationScreen( // Corrected
//               orderId: orderId!,
//               buyerFullName: buyerFullName,
//               deliveryLocation: deliveryLocation,
//               totalOrderPrice: totalOrderPrice,
//               paymentMethod: _selectedPaymentMethod!,
//               cartItems: widget.cartItems,
//               orderDateTime: orderDateTime,
//             ),
//           ),
//         );
//       }
//
//     } catch (e, stackTrace) {
//       if (mounted) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).pop();
//         }
//       }
//       print("ERROR: Error placing order: $e");
//       print("ERROR: Stack trace: $stackTrace");
//       _showSnackBar("Error placing order. Please try again.");
//     }
//   }
//
//   Future<String> _createOrderDocument(Transaction? transaction, String buyerId, double totalOrderPrice) async {
//     final orderItemsData = widget.cartItems.map((item) => {
//       'itemId': item.itemId,
//       'name': item.name,
//       'price': item.price,
//       'quantity': item.quantity,
//       'imageUrl': item.imageUrl,
//       'sellerId': item.sellerId,
//       'sellerName': item.sellerName,
//     }).toList();
//
//     final orderData = {
//       'buyerId': buyerId,
//       'buyerFullName': _fullNameController.text.trim(),
//       'buyerPhoneNumber': _phoneNumberController.text.trim(),
//       'deliveryLocation': _locationController.text.trim(),
//       'items': orderItemsData,
//       'totalPrice': totalOrderPrice,
//       'paymentMethod': _selectedPaymentMethod,
//       'orderStatus': 'pending',
//       'orderDate': FieldValue.serverTimestamp(),
//       'txRef': 'ORDER-${DateTime.now().millisecondsSinceEpoch}-${buyerId}',
//     };
//
//     DocumentReference orderRef;
//     if (transaction != null) {
//       orderRef = FirebaseFirestore.instance.collection('orders').doc();
//       transaction.set(orderRef, orderData);
//     } else {
//       orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);
//     }
//     return orderRef.id;
//   }
//
//   Future<void> _processSellerPayments(Transaction? transaction, String buyerId, String? orderId) async {
//     Map<String, double> sellerEarnings = {};
//     for (var item in widget.cartItems) {
//       sellerEarnings.update(item.sellerId, (value) => value + (item.price * item.quantity),
//           ifAbsent: () => (item.price * item.quantity));
//     }
//
//     for (var entry in sellerEarnings.entries) {
//       final sellerId = entry.key;
//       final earnings = entry.value;
//
//       final sellerWalletRef = FirebaseFirestore.instance.collection('users').doc(sellerId);
//       final sellerTransactionsRef = sellerWalletRef.collection('transactions');
//
//       if (transaction != null) {
//         final sellerDoc = await transaction.get(sellerWalletRef);
//         final currentSellerBalance = (sellerDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//         transaction.update(sellerWalletRef, {'walletBalance': currentSellerBalance + earnings});
//
//         transaction.set(sellerTransactionsRef.doc(), {
//           'type': 'sale_credit',
//           'amount': earnings,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Credit from sale of items in order by $buyerId',
//           'relatedOrderId': orderId,
//         });
//       } else {
//         await sellerWalletRef.update({'walletBalance': FieldValue.increment(earnings)});
//         await sellerTransactionsRef.add({
//           'type': 'sale_credit',
//           'amount': earnings,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Credit from sale of items in order by $buyerId',
//           'relatedOrderId': orderId,
//         });
//       }
//     }
//
//     if (_selectedPaymentMethod == 'Wallet' || _selectedPaymentMethod == 'Mobile Money') {
//       final buyerTransactionsRef = FirebaseFirestore.instance.collection('users').doc(buyerId).collection('transactions');
//       final double totalOrderPrice = Provider.of<CartModel>(context, listen: false).totalPrice;
//
//       if (transaction != null) {
//         transaction.set(buyerTransactionsRef.doc(), {
//           'type': 'purchase_debit',
//           'amount': -totalOrderPrice,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Debit for order placed: $orderId',
//           'relatedOrderId': orderId,
//         });
//       } else {
//         await buyerTransactionsRef.add({
//           'type': 'purchase_debit',
//           'amount': -totalOrderPrice,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Debit for order placed: $orderId',
//           'relatedOrderId': orderId,
//         });
//       }
//     }
//   }
//
//   Future<void> _sendOrderNotificationsToSellers(
//       String buyerId,
//       String buyerFullName,
//       String buyerPhoneNumber,
//       String deliveryLocation,
//       String orderId,
//       List<CartItem> purchasedItems) async {
//     final Map<String, List<CartItem>> itemsBySeller = {};
//     for (var item in purchasedItems) {
//       itemsBySeller.putIfAbsent(item.sellerId, () => []).add(item);
//     }
//
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final Uuid uuid = Uuid();
//
//     for (var entry in itemsBySeller.entries) {
//       final String sellerId = entry.key;
//       final List<CartItem> sellerSpecificItems = entry.value;
//
//       List<String> participants = [buyerId, sellerId]..sort();
//       String chatId = participants.join('_');
//
//       String sellerName = "Seller";
//       try {
//         DocumentSnapshot sellerDoc = await _firestore.collection('users').doc(sellerId).get();
//         if (sellerDoc.exists) {
//           final Map<String, dynamic>? sellerData = sellerDoc.data() as Map<String, dynamic>?;
//
//           if (sellerData != null) {
//             sellerName = (sellerData['fullName'] as String?) ??
//                 (sellerData['username'] as String?) ??
//                 "Seller";
//           }
//         }
//       } catch (e) {
//         print("Error fetching seller name for notification: $e");
//       }
//
//       String itemDetails = sellerSpecificItems
//           .map((item) => "- ${item.name} (x${item.quantity}) for ₵${(item.price * item.quantity).toStringAsFixed(2)}")
//           .join('\n');
//
//       String messageText =
//           "New Order from $buyerFullName for your items!\n\n"
//           "Order ID: $orderId\n"
//           "Items:\n$itemDetails\n\n"
//           "Buyer Contact: $buyerPhoneNumber\n"
//           "Delivery Location: $deliveryLocation\n\n"
//           "Please arrange pickup/delivery with the buyer.";
//
//       DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
//       await chatRef.set({
//         'participants': participants,
//         'lastMessage': "New order for your items (ID: $orderId)",
//         'lastMessageTimestamp': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       await chatRef.collection('messages').doc(uuid.v4()).set({
//         'senderId': buyerId,
//         'recipientId': sellerId,
//         'text': messageText,
//         'timestamp': FieldValue.serverTimestamp(),
//         'read': false,
//         'type': 'order_notification',
//         'orderId': orderId,
//       });
//
//       print("Sent order notification to seller: $sellerName ($sellerId)");
//     }
//   }
//
//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   void _showLoadingDialog(String message) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Row(
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(width: 20),
//                 Text(message),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   void _showInsufficientFundsDialog(double neededAmount) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Insufficient Funds"),
//             content: Text("Your wallet balance is not enough. You need ₵${neededAmount.toStringAsFixed(2)} more. Do you want to top up your wallet?"),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("Cancel"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 child: const Text("Top Up Wallet"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) =>  WalletScreen()),
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneNumberController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cartModel = Provider.of<CartModel>(context);
//     final double totalOrderPrice = cartModel.totalPrice;
//
//     final bool canUseWallet = _userWalletBalance >= totalOrderPrice;
//     final bool canUseMobile = _userWalletBalance >= totalOrderPrice;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Checkout"),
//         backgroundColor: const Color(0xFF004D40),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section 1: Delivery Information
//             const Text(
//               "1. Delivery Information",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _fullNameController,
//                     decoration: const InputDecoration(
//                       labelText: "Full Name",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your full name.';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _phoneNumberController,
//                     keyboardType: TextInputType.phone,
//                     decoration: const InputDecoration(
//                         labelText: "Phone Number",
//                         border: OutlineInputBorder(),
//                         hintText: "e.g., 0551234567"
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your phone number.';
//                       }
//                       if (value.trim().length < 10) {
//                         return 'Phone number is too short.';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _locationController,
//                     decoration: const InputDecoration(
//                         labelText: "Pickup/Delivery Location (e.g., Hostel Block, Room No.)",
//                         border: OutlineInputBorder(),
//                         hintText: "e.g., Volta Hall, Room 205"
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your pickup/delivery location.';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Section 2: Order Summary
//             const Text(
//               "2. Order Summary",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     ...widget.cartItems.map((item) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(child: Text("${item.name} (x${item.quantity}) from ${item.sellerName}")),
//                           Text("₵${(item.price * item.quantity).toStringAsFixed(2)}"),
//                         ],
//                       ),
//                     )).toList(),
//                     const Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text("Total Price:", style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text("₵${totalOrderPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Section 3: Payment Method
//             const Text(
//               "3. Payment Method",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             _isLoadingWallet
//                 ? const Center(child: CircularProgressIndicator())
//                 : Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     RadioListTile<String>(
//                       title: const Text("In-Person (Pay on Pickup/Delivery)"),
//                       value: 'In-Person',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       },
//                       activeColor: const Color(0xFF004D40),
//                     ),
//
//                     RadioListTile<String>(
//                       title: Text(
//                         "Wallet (Balance: ₵${_userWalletBalance.toStringAsFixed(2)})",
//                         style: TextStyle(
//                           color: canUseWallet ? Colors.black : Colors.grey[600],
//                         ),
//                       ),
//                       value: 'Wallet',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: canUseWallet ? (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       } : null,
//                       activeColor: const Color(0xFF004D40),
//                     ),
//
//                     RadioListTile<String>(
//                       title: Text(
//                         "Mobile Money (MTN, Vodafone, AirtelTigo)",
//                         style: TextStyle(
//                           color: canUseMobile ? Colors.black : Colors.grey[600],
//                         ),
//                       ),
//                       value: 'Mobile Money',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: canUseMobile ? (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       } : null,
//                       activeColor: const Color(0xFF004D40),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Final: Place Order Button
//             ElevatedButton(
//               onPressed: _placeOrder,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF004D40),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text(
//                 "Place Order",
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }














import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:UniTrade/models/cart_model.dart';
import 'package:UniTrade/screens/wallet_page.dart';


class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems; // Re-introduced cartItems parameter

  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key); // Updated constructor

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedPaymentMethod = 'In-Person'; // Default to In-Person
  double _userWalletBalance = 0.0;
  bool _isLoadingWallet = true;

  // Store the total price of the order at the time of checkout screen creation
  double _orderPriceAtCheckout = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndWalletBalance();
    // Calculate total price based on the passed cartItems
    _orderPriceAtCheckout = widget.cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _loadUserDataAndWalletBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          _fullNameController.text = userData?['fullName'] ?? '';
          _phoneNumberController.text = userData?['phoneNumber'] ?? '';

          setState(() {
            _userWalletBalance = (userData?['walletBalance'] as num?)?.toDouble() ?? 0.0;
            _isLoadingWallet = false;
          });
        }
      } catch (e) {
        print("Error loading user data or wallet balance: $e");
        setState(() {
          _isLoadingWallet = false;
        });
      }
    } else {
      setState(() {
        _isLoadingWallet = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    // 1. Validate Delivery Info using the Form Key
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill in all required delivery details.");
      return;
    }

    // 2. Validate Payment Method
    if (_selectedPaymentMethod == null) {
      _showSnackBar("Please select a payment method.");
      return;
    }

    // Handle Wallet payment option (simplified for display purposes)
    if (_selectedPaymentMethod == 'Wallet') {
      if (_userWalletBalance < _orderPriceAtCheckout) {
        _showInsufficientFundsDialog(_orderPriceAtCheckout - _userWalletBalance);
        return;
      }
      // In a real app, you would deduct from wallet balance here and save to Firestore
    }

    _showLoadingDialog("Processing order...");
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay or processing

    final cartModel = Provider.of<CartModel>(context, listen: false);

    // IMPORTANT: Mark cart as completed and clear the active cart AFTER confirmation and processing simulation
    cartModel.markCartAsCompleted(); // Move this here
    cartModel.clearCart(); // This clears the active cart in Firestore and in-memory

    // Dismiss the loading dialog
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Show the success dialog using the captured _orderPriceAtCheckout
    _showSuccessDialog("Your order has been placed!", _orderPriceAtCheckout);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showLoadingDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(message),
              ],
            ),
          );
        },
      );
    }
  }

  void _showInsufficientFundsDialog(double neededAmount) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Insufficient Funds"),
            content: Text("Your wallet balance is not enough. You need ₵${neededAmount.toStringAsFixed(2)} more. Do you want to top up your wallet?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Top Up Wallet"),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) =>  WalletScreen()),
                  // );
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showSuccessDialog(String message, double totalOrderPrice) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text("Order Placed!"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 10),
                Text(
                  "Total amount: ₵${totalOrderPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("You'll receive a confirmation message shortly."),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss success dialog
                  Navigator.of(context).pop(); // Go back to CartScreen (or wherever previous screen was)
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use _orderPriceAtCheckout which was calculated from widget.cartItems in initState
    final double totalOrderPrice = _orderPriceAtCheckout;
    final bool canUseWallet = _userWalletBalance >= totalOrderPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Delivery Information
            const Text(
              "1. Delivery Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                        hintText: "e.g., 0551234567"
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number.';
                      }
                      if (value.trim().length < 10) {
                        return 'Phone number is too short.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                        labelText: "Pickup/Delivery Location (e.g., Hostel Block, Room No.)",
                        border: OutlineInputBorder(),
                        hintText: "e.g., Volta Hall, Room 205"
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your pickup/delivery location.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Section 2: Order Summary - Now correctly displays items from widget.cartItems
            const Text(
              "2. Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Iterate through widget.cartItems to display order summary
                    ...widget.cartItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${item.name} (x${item.quantity}) from ${item.sellerName}")),
                          Text("₵${(item.price * item.quantity).toStringAsFixed(2)}"),
                        ],
                      ),
                    )).toList(),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Price:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₵${totalOrderPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Section 3: Payment Method
            const Text(
              "3. Payment Method",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 10),
            _isLoadingWallet
                ? const Center(child: CircularProgressIndicator())
                : Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("In-Person (Pay on Pickup/Delivery)"),
                      value: 'In-Person',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                      activeColor: const Color(0xFF004D40),
                    ),

                    RadioListTile<String>(
                      title: Text(
                        "Wallet (Balance: ₵${_userWalletBalance.toStringAsFixed(2)})",
                        style: TextStyle(
                          color: canUseWallet ? Colors.black : Colors.grey[600], // Gray out if not usable
                        ),
                      ),
                      value: 'Wallet',
                      groupValue: _selectedPaymentMethod,
                      onChanged: canUseWallet ? (String? value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      } : null, // Disable if not enough funds
                      activeColor: const Color(0xFF004D40),
                    ),

                    RadioListTile<String>(
                      title: const Text("Mobile Money (MTN, Vodafone, AirtelTigo)"),
                      value: 'Mobile Money',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                      activeColor: const Color(0xFF004D40),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Final: Place Order Button
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Place Order",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



































// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for _loadUserDataAndWalletBalance
// import 'package:firebase_auth/firebase_auth.dart'; // Still needed for _loadUserDataAndWalletBalance
// import 'package:UniTrade/models/cart_model.dart';
// import 'package:UniTrade/screens/wallet_page.dart'; // Still potentially needed if user navigates there
//
//
// class CheckoutScreen extends StatefulWidget {
//   final List<CartItem> cartItems;
//
//   const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//
//   String? _selectedPaymentMethod = 'In-Person'; // Default to In-Person
//   double _userWalletBalance = 0.0;
//   bool _isLoadingWallet = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDataAndWalletBalance();
//   }
//
//   // This function is kept to pre-fill user's name and phone number
//   // and display a wallet balance (even if not used for payment logic)
//   Future<void> _loadUserDataAndWalletBalance() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//         if (userDoc.exists) {
//           final userData = userDoc.data();
//           _fullNameController.text = userData?['fullName'] ?? '';
//           _phoneNumberController.text = userData?['phoneNumber'] ?? '';
//
//           setState(() {
//             _userWalletBalance = (userData?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//             _isLoadingWallet = false;
//           });
//         }
//       } catch (e) {
//         print("Error loading user data or wallet balance: $e");
//         setState(() {
//           _isLoadingWallet = false;
//         });
//       }
//     } else {
//       setState(() {
//         _isLoadingWallet = false;
//       });
//     }
//   }
//
//   // SIMPLIFIED _placeOrder function - no Firebase order processing
//   Future<void> _placeOrder() async {
//     // 1. Validate Delivery Info using the Form Key
//     if (!_formKey.currentState!.validate()) {
//       _showSnackBar("Please fill in all required delivery details.");
//       return;
//     }
//
//     // 2. Validate Payment Method
//     if (_selectedPaymentMethod == null) {
//       _showSnackBar("Please select a payment method.");
//       return;
//     }
//
//     // Simulate processing time
//     _showLoadingDialog("Processing order...");
//     await Future.delayed(const Duration(seconds: 2)); // Simulate network delay or processing
//
//     // Get cart total for display in success message
//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     final double totalOrderPrice = cartModel.totalPrice;
//
//     // Clear the cart immediately
//     cartModel.clearCart();
//
//     // Dismiss the loading dialog
//     if (mounted && Navigator.of(context).canPop()) {
//       Navigator.of(context).pop();
//     }
//
//     // Show the success dialog
//     // The message can be simplified since no actual transaction/order ID is generated here.
//     _showSuccessDialog("Your order has been placed!", totalOrderPrice);
//   }
//
//   // --- REMOVED: _createOrderDocument is no longer needed ---
//   // Future<String> _createOrderDocument(...) { ... }
//
//   // --- REMOVED: _processSellerPayments is no longer needed ---
//   // Future<void> _processSellerPayments(...) { ... }
//
//   // --- REMOVED: _sendOrderNotificationsToSellers is no longer needed ---
//   // Future<void> _sendOrderNotificationsToSellers(...) { ... }
//
//
//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   void _showLoadingDialog(String message) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Row(
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(width: 20),
//                 Text(message),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   void _showInsufficientFundsDialog(double neededAmount) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Insufficient Funds"),
//             content: Text("Your wallet balance is not enough. You need ₵${neededAmount.toStringAsFixed(2)} more. Do you want to top up your wallet?"),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("Cancel"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 child: const Text("Top Up Wallet"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) =>  WalletScreen()),
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   // Re-added _showSuccessDialog as it's now the target
//   void _showSuccessDialog(String message, double totalOrderPrice) {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Row(
//               children: [
//                 Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
//                 SizedBox(width: 10),
//                 Text("Order Placed!"),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(message),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Total amount: ₵${totalOrderPrice.toStringAsFixed(2)}",
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text("You'll receive a confirmation message shortly."), // Simplified message
//               ],
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Dismiss success dialog
//                   Navigator.of(context).pop(); // Go back to CartScreen (or wherever previous screen was)
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneNumberController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cartModel = Provider.of<CartModel>(context);
//     final double totalOrderPrice = cartModel.totalPrice;
//
//     final bool canUseWallet = _userWalletBalance >= totalOrderPrice;
//     // Mobile Money availability is no longer tied to wallet balance in this simplified version
//     // It's effectively always selectable if _selectedPaymentMethod is set properly.
//     // Removed `canUseMobile` as it's no longer necessary for the simplified flow's UI logic.
//     // However, if you want it to appear greyed out, simply set onChanged to null.
//     // For now, I'll make it always enabled as it's just a selection for a simulated flow.
//     // If you want it greyed out, change onChanged to null and text style color to grey.
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Checkout"),
//         backgroundColor: const Color(0xFF004D40),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section 1: Delivery Information
//             const Text(
//               "1. Delivery Information",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _fullNameController,
//                     decoration: const InputDecoration(
//                       labelText: "Full Name",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your full name.';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _phoneNumberController,
//                     keyboardType: TextInputType.phone,
//                     decoration: const InputDecoration(
//                         labelText: "Phone Number",
//                         border: OutlineInputBorder(),
//                         hintText: "e.g., 0551234567"
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your phone number.';
//                       }
//                       if (value.trim().length < 10) {
//                         return 'Phone number is too short.';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _locationController,
//                     decoration: const InputDecoration(
//                         labelText: "Pickup/Delivery Location (e.g., Hostel Block, Room No.)",
//                         border: OutlineInputBorder(),
//                         hintText: "e.g., Volta Hall, Room 205"
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your pickup/delivery location.';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Section 2: Order Summary
//             const Text(
//               "2. Order Summary",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     ...widget.cartItems.map((item) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(child: Text("${item.name} (x${item.quantity}) from ${item.sellerName}")),
//                           Text("₵${(item.price * item.quantity).toStringAsFixed(2)}"),
//                         ],
//                       ),
//                     )).toList(),
//                     const Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text("Total Price:", style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text("₵${totalOrderPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Section 3: Payment Method
//             const Text(
//               "3. Payment Method",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//             ),
//             const SizedBox(height: 10),
//             _isLoadingWallet
//                 ? const Center(child: CircularProgressIndicator())
//                 : Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     RadioListTile<String>(
//                       title: const Text("In-Person (Pay on Pickup/Delivery)"),
//                       value: 'In-Person',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       },
//                       activeColor: const Color(0xFF004D40),
//                     ),
//
//                     RadioListTile<String>(
//                       title: Text(
//                         "Wallet (Balance: ₵${_userWalletBalance.toStringAsFixed(2)})",
//                         style: TextStyle(
//                           color: canUseWallet ? Colors.black : Colors.grey[600],
//                         ),
//                       ),
//                       value: 'Wallet',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: canUseWallet ? (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       } : null,
//                       activeColor: const Color(0xFF004D40),
//                     ),
//
//                     // Mobile Money is always enabled in this simplified flow
//                     RadioListTile<String>(
//                       title: const Text("Mobile Money (MTN, Vodafone, AirtelTigo)"),
//                       value: 'Mobile Money',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       },
//                       activeColor: const Color(0xFF004D40),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Final: Place Order Button
//             ElevatedButton(
//               onPressed: _placeOrder, // This now calls the simplified function
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF004D40),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text(
//                 "Place Order",
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
