//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:UniTrade/models/cart_model.dart'; // Correctly imports CartModel and CartItem
// // REMOVE THIS LINE: import 'package:UniTrade/screens/cart_screen.dart'; // This import is unnecessary here
// import 'package:UniTrade/screens/wallet_page.dart'; // Ensure this is correctly imported
// // If you're using url_launcher for MoMo, ensure it's imported:
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:cloud_functions/cloud_functions.dart'; // If using Firebase Functions
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
//   // User delivery details
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//
//   // Payment method selection
//   String? _selectedPaymentMethod; // e.g., 'Wallet', 'Mobile Money'
//
//   // User wallet balance (to be fetched)
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
//           // Assuming location details are not typically stored on user doc for pickup
//           // You might need a separate address management system for delivery.
//           // For now, location field is user input.
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
//     // 1. Validate Delivery Info
//     if (_fullNameController.text.trim().isEmpty ||
//         _phoneNumberController.text.trim().isEmpty ||
//         _locationController.text.trim().isEmpty) {
//       if (mounted) Navigator.of(context).pop(); // Dismiss loading if it was shown
//       _showSnackBar("Please fill in all delivery details.");
//       return;
//     }
//
//     // 2. Validate Payment Method
//     if (_selectedPaymentMethod == null) {
//       if (mounted) Navigator.of(context).pop(); // Dismiss loading if it was shown
//       _showSnackBar("Please select a payment method.");
//       return;
//     }
//
//     // Show loading dialog *before* async operations that might take time
//     _showLoadingDialog("Processing order...");
//
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       if (mounted) Navigator.of(context).pop(); // Dismiss loading
//       _showSnackBar("You must be logged in to place an order.");
//       return;
//     }
//
//     final String buyerId = user.uid;
//     // Get CartModel instance WITHOUT listening (listen: false) before async operations
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
//
//         });
//
//         // --- SUCCESSFUL WALLET PAYMENT & ORDER PLACEMENT ---
//         // Clear cart IMMEDIATELY after successful transaction logic
//         cartModel.clearCart();
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading
//         _showSuccessDialog("Order placed successfully via Wallet!");
//
//
//       } else if (_selectedPaymentMethod == 'Mobile Money') {
//         // --- Initiate Mobile Money Payment (Firebase Cloud Function essential) ---
//         // This part would ideally connect to a payment gateway API via a Cloud Function.
//         // For demonstration, we simulate success directly here.
//
//         // Dismiss loading dialog first as external action is needed
//         if (mounted) Navigator.of(context).pop();
//         _showLoadingDialog("Please complete Mobile Money payment in the external window/app."); // New message
//
//         // In a real app, the user would complete payment and then a webhook would confirm and create order
//         // For now, let's simulate order creation after a short delay for demo.
//         await Future.delayed(const Duration(seconds: 3)); // Simulate external payment time
//
//         // This part would be inside a Cloud Function webhook callback on successful payment
//         // For demo, we're doing it here, but in production, this should be server-side after successful payment confirmation
//         orderId = await _createOrderDocument(null, buyerId, totalOrderPrice);
//         await _processSellerPayments(null, buyerId, orderId); // Sellers also get paid on simulated MoMo success
//
//         // Clear cart AFTER simulated successful payment and order/seller processing
//         cartModel.clearCart();
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading
//         _showSuccessDialog("Order placed successfully via Mobile Money (pending payment confirmation)!");
//
//       } else {
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
//   // Now returns the order ID
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
//       // If part of an existing transaction (e.g., wallet payment)
//       orderRef = FirebaseFirestore.instance.collection('orders').doc(); // Create new doc reference
//       transaction.set(orderRef, orderData);
//     } else {
//       // If not part of a transaction (e.g., MoMo, handled by webhook later)
//       orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);
//     }
//     return orderRef.id; // Return the ID of the created order
//   }
//
//   // Helper to process seller payments (add to seller wallet)
//   // Modified to optionally accept a transaction or directly update (for MoMo demo)
//   // Now accepts orderId
//   Future<void> _processSellerPayments(Transaction? transaction, String buyerId, String? orderId) async {
//     // Group items by seller
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
//       if (transaction != null) {
//         final sellerDoc = await transaction.get(sellerWalletRef);
//         final currentSellerBalance = (sellerDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
//         transaction.update(sellerWalletRef, {'walletBalance': currentSellerBalance + earnings});
//
//         // Add transaction record for seller (within transaction if possible)
//         // Note: Adding to a different collection within the same transaction requires specific index rules.
//         // For simplicity here, we're keeping it outside the main user wallet transaction if not part of it.
//         // For production, all these should be handled by Cloud Functions.
//         await FirebaseFirestore.instance.collection('transactions').add({
//           'userId': sellerId,
//           'type': 'sale_credit',
//           'amount': earnings,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Credit from sale of items in order by $buyerId',
//           'relatedOrderId': orderId, // Use the generated order ID
//         });
//       } else {
//         // Direct update for MoMo simulation
//         await sellerWalletRef.update({'walletBalance': FieldValue.increment(earnings)});
//         // Add transaction record for seller
//         await FirebaseFirestore.instance.collection('transactions').add({
//           'userId': sellerId,
//           'type': 'sale_credit',
//           'amount': earnings,
//           'currency': 'GHS',
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'completed',
//           'description': 'Credit from sale of items in order by $buyerId',
//           'relatedOrderId': orderId, // Use the generated order ID
//         });
//       }
//     }
//   }
//
//
//   void _showSnackBar(String message) {
//     // Ensure context is still valid before showing SnackBar
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   void _showLoadingDialog(String message) {
//     // Ensure context is still valid before showing dialog
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
//     if (mounted) { // Check if mounted before showing dialog
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
//                   Navigator.of(context).pop(); // Dismiss dialog
//                 },
//               ),
//               TextButton(
//                 child: const Text("Top Up Wallet"),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Dismiss dialog
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) =>  WalletScreen()), // Navigate to WalletScreen
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
//   void _showSuccessDialog(String message) {
//     if (mounted) { // Check if mounted before showing dialog
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Order Placed!"),
//             content: Text(message),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Dismiss dialog
//                   // Only pop once to go back to CartScreen after clearing the cart
//                   // The cart is already cleared, so no need to pop again here.
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
//             TextField(
//               controller: _fullNameController,
//               decoration: const InputDecoration(
//                 labelText: "Full Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _phoneNumberController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: "Phone Number",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _locationController,
//               decoration: const InputDecoration(
//                 labelText: "Pickup/Delivery Location (e.g., Hostel Block, Room No.)",
//                 border: OutlineInputBorder(),
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
//                       title: Text("Wallet (Balance: ₵${_userWalletBalance.toStringAsFixed(2)})"),
//                       value: 'Wallet',
//                       groupValue: _selectedPaymentMethod,
//                       onChanged: (String? value) {
//                         setState(() {
//                           _selectedPaymentMethod = value;
//                         });
//                       },
//                       activeColor: const Color(0xFF004D40),
//                     ),
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
//                     ),
//                     // You can add more payment options here (e.g., 'Card')
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
import 'package:UniTrade/models/cart_model.dart'; // Correctly imports CartModel and CartItem
import 'package:UniTrade/screens/wallet_page.dart'; // Ensure this is correctly imported

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems; // Pass cart items to the checkout screen

  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Add a GlobalKey for the Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // User delivery details
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Payment method selection
  String? _selectedPaymentMethod; // e.g., 'Wallet', 'Mobile Money'

  // User wallet balance (to be fetched)
  double _userWalletBalance = 0.0;
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndWalletBalance();
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
      return; // Stop if form is not valid
    }

    // 2. Validate Payment Method
    if (_selectedPaymentMethod == null) {
      _showSnackBar("Please select a payment method.");
      return; // Stop if no payment method is selected
    }

    // Show loading dialog *before* async operations that might take time
    _showLoadingDialog("Processing order...");


    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop(); // Dismiss loading
      _showSnackBar("You must be logged in to place an order.");
      return;
    }

    final String buyerId = user.uid;
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final double totalOrderPrice = cartModel.totalPrice;

    try {
      String? orderId; // To store the generated order ID

      if (_selectedPaymentMethod == 'Wallet') {
        if (_userWalletBalance < totalOrderPrice) {
          if (mounted) Navigator.of(context).pop(); // Dismiss loading
          _showInsufficientFundsDialog(totalOrderPrice - _userWalletBalance);
          return;
        }

        final userWalletRef = FirebaseFirestore.instance.collection('users').doc(buyerId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userDoc = await transaction.get(userWalletRef);
          final currentBalance = (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;

          if (currentBalance < totalOrderPrice) {
            throw Exception("Insufficient funds during transaction."); // Re-check
          }

          transaction.update(userWalletRef, {'walletBalance': currentBalance - totalOrderPrice});

          // Create order document and get its ID
          orderId = await _createOrderDocument(transaction, buyerId, totalOrderPrice);

          // Update sellers' balances and create seller transaction records
          await _processSellerPayments(transaction, buyerId, orderId);

        });

        // --- SUCCESSFUL WALLET PAYMENT & ORDER PLACEMENT ---
        // Clear cart IMMEDIATELY after successful transaction logic
        cartModel.clearCart();
        if (mounted) Navigator.of(context).pop(); // Dismiss loading
        _showSuccessDialog("Order placed successfully via Wallet!");


      } else if (_selectedPaymentMethod == 'Mobile Money') {
        // Dismiss loading dialog first as external action is needed
        if (mounted) Navigator.of(context).pop();
        _showLoadingDialog("Please complete Mobile Money payment in the external window/app."); // New message

        await Future.delayed(const Duration(seconds: 3)); // Simulate external payment time

        orderId = await _createOrderDocument(null, buyerId, totalOrderPrice);
        await _processSellerPayments(null, buyerId, orderId); // Sellers also get paid on simulated MoMo success

        // Clear cart AFTER simulated successful payment and order/seller processing
        cartModel.clearCart();
        if (mounted) Navigator.of(context).pop(); // Dismiss loading
        _showSuccessDialog("Order placed successfully via Mobile Money (pending payment confirmation)!");

      } else {
        if (mounted) Navigator.of(context).pop(); // Dismiss loading
        _showSnackBar("Invalid payment method selected.");
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Dismiss loading
      print("Error placing order: $e");
      _showSnackBar("Error placing order. Please try again.");
    }
  }

  // Helper to create the order document in Firestore
  Future<String> _createOrderDocument(Transaction? transaction, String buyerId, double totalOrderPrice) async {
    final orderItemsData = widget.cartItems.map((item) => {
      'itemId': item.itemId,
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'imageUrl': item.imageUrl,
      'sellerId': item.sellerId,
      'sellerName': item.sellerName,
    }).toList();

    final orderData = {
      'buyerId': buyerId,
      'buyerFullName': _fullNameController.text.trim(),
      'buyerPhoneNumber': _phoneNumberController.text.trim(),
      'deliveryLocation': _locationController.text.trim(),
      'items': orderItemsData,
      'totalPrice': totalOrderPrice,
      'paymentMethod': _selectedPaymentMethod,
      'orderStatus': 'pending', // Initial status
      'orderDate': FieldValue.serverTimestamp(),
      'txRef': 'ORDER-${DateTime.now().millisecondsSinceEpoch}-${buyerId}', // Unique reference for the order
    };

    DocumentReference orderRef;
    if (transaction != null) {
      orderRef = FirebaseFirestore.instance.collection('orders').doc();
      transaction.set(orderRef, orderData);
    } else {
      orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);
    }
    return orderRef.id;
  }

  // Helper to process seller payments (add to seller wallet)
  Future<void> _processSellerPayments(Transaction? transaction, String buyerId, String? orderId) async {
    Map<String, double> sellerEarnings = {};
    for (var item in widget.cartItems) {
      sellerEarnings.update(item.sellerId, (value) => value + (item.price * item.quantity),
          ifAbsent: () => (item.price * item.quantity));
    }

    for (var entry in sellerEarnings.entries) {
      final sellerId = entry.key;
      final earnings = entry.value;

      final sellerWalletRef = FirebaseFirestore.instance.collection('users').doc(sellerId);

      if (transaction != null) {
        final sellerDoc = await transaction.get(sellerWalletRef);
        final currentSellerBalance = (sellerDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
        transaction.update(sellerWalletRef, {'walletBalance': currentSellerBalance + earnings});

        await FirebaseFirestore.instance.collection('transactions').add({
          'userId': sellerId,
          'type': 'sale_credit',
          'amount': earnings,
          'currency': 'GHS',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': 'Credit from sale of items in order by $buyerId',
          'relatedOrderId': orderId,
        });
      } else {
        await sellerWalletRef.update({'walletBalance': FieldValue.increment(earnings)});
        await FirebaseFirestore.instance.collection('transactions').add({
          'userId': sellerId,
          'type': 'sale_credit',
          'amount': earnings,
          'currency': 'GHS',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': 'Credit from sale of items in order by $buyerId',
          'relatedOrderId': orderId,
        });
      }
    }
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  WalletScreen()),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showSuccessDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Order Placed!"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to CartScreen
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
    final cartModel = Provider.of<CartModel>(context);
    final double totalOrderPrice = cartModel.totalPrice;

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
            // >>>>>>>>>>>>> WRAP IN FORM WIDGET <<<<<<<<<<<<<<<<
            Form(
              key: _formKey, // Assign the form key
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                    // Add validator
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
                    ),
                    // Add validator
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number.';
                      }
                      // Basic phone number validation (you might want a more robust regex)
                      if (value.trim().length < 10) { // Assuming Ghanaian numbers are at least 10 digits
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
                    ),
                    // Add validator
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
            // >>>>>>>>>>>>> END FORM WIDGET <<<<<<<<<<<<<<<<
            const SizedBox(height: 30),

            // Section 2: Order Summary
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
                      title: Text("Wallet (Balance: ₵${_userWalletBalance.toStringAsFixed(2)})"),
                      value: 'Wallet',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
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
                    ),
                    // You can add more payment options here (e.g., 'Card')
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