// import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart'; // For date formatting
// import 'package:UniTrade/models/cart_model.dart'; // Assuming CartItem is here
// import 'package:UniTrade/screens/home_screen.dart'; // Assuming you have a main screen to navigate back to
//
// class ConfirmationPage extends StatelessWidget {
//   final String orderId;
//   final String buyerFullName;
//   final String deliveryLocation;
//   final double totalOrderPrice;
//   final String paymentMethod;
//   final List<CartItem> cartItems;
//   final DateTime orderDateTime;
//
//   const ConfirmationPage({
//     Key? key,
//     required this.orderId,
//     required this.buyerFullName,
//     required this.deliveryLocation,
//     required this.totalOrderPrice,
//     required this.paymentMethod,
//     required this.cartItems,
//     required this.orderDateTime,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Calculate total number of items
//     int totalItemsCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
//
//     // Format date and time
//     // String formattedDate = DateFormat('yyyy-MM-dd').format(orderDateTime);
//     // String formattedTime = DateFormat('HH:mm:ss').format(orderDateTime);
//
//     return WillPopScope(
//       onWillPop: () async {
//         // Prevent going back to checkout, navigate to home/main screen
//         Navigator.of(context).popUntil((route) => route.isFirst); // Go to the very first route (usually home)
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your actual MainScreen/HomeScreen
//         );
//         return false; // Prevent default back button behavior
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Order Confirmed!"),
//           backgroundColor: const Color(0xFF004D40),
//           foregroundColor: Colors.white,
//           automaticallyImplyLeading: false, // Disable back button
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Card(
//             elevation: 8,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Center(
//                     child: Icon(
//                       Icons.check_circle_outline,
//                       color: Colors.green,
//                       size: 80,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   const Center(
//                     child: Text(
//                       "Your Order Has Been Placed!",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF004D40),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   buildReceiptRow("Order ID:", orderId),
//                   buildReceiptRow("Buyer Name:", buyerFullName),
//                   buildReceiptRow("Delivery Location:", deliveryLocation),
//                   // buildReceiptRow("Order Date:", formattedDate),
//                   // buildReceiptRow("Order Time:", formattedTime),
//                   buildReceiptRow("Payment Method:", paymentMethod),
//                   buildReceiptRow("Total Items:", totalItemsCount.toString()),
//                   const Divider(height: 30, thickness: 2),
//                   const Text(
//                     "Items Purchased:",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   ...cartItems.map((item) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "${item.name} (x${item.quantity})",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         Text(
//                           "₵${(item.price * item.quantity).toStringAsFixed(2)}",
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                   )).toList(),
//                   const Divider(height: 30, thickness: 2),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Total Amount Paid:",
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         "₵${totalOrderPrice.toStringAsFixed(2)}",
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Navigate to the main screen, clear all previous routes
//                         Navigator.of(context).popUntil((route) => route.isFirst);
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your actual MainScreen/HomeScreen
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF004D40),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                       child: const Text(
//                         "Back to Home",
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildReceiptRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Still needed for date formatting
import 'package:UniTrade/models/cart_model.dart';
import 'package:UniTrade/screens/home_screen.dart'; // Corrected: home_screen

class ConfirmationScreen extends StatelessWidget { // Corrected: ConfirmationScreen
  final String orderId;
  final String buyerFullName;
  final String deliveryLocation;
  final double totalOrderPrice;
  final String paymentMethod;
  final List<CartItem> cartItems;
  final DateTime orderDateTime;

  const ConfirmationScreen({ // Corrected: ConfirmationScreen
    Key? key,
    required this.orderId,
    required this.buyerFullName,
    required this.deliveryLocation,
    required this.totalOrderPrice,
    required this.paymentMethod,
    required this.cartItems,
    required this.orderDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalItemsCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

    // Format date and time using intl
    String formattedDate = DateFormat('yyyy-MM-dd').format(orderDateTime);
    String formattedTime = DateFormat('HH:mm:ss').format(orderDateTime);

    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to checkout, navigate to home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Corrected: HomeScreen
        );
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Order Confirmed!"),
          backgroundColor: const Color(0xFF004D40),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Disable back button
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
                      "Your Order Has Been Placed!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 25),
                  buildReceiptRow("Order ID:", orderId),
                  buildReceiptRow("Buyer Name:", buyerFullName),
                  buildReceiptRow("Delivery Location:", deliveryLocation),
                  buildReceiptRow("Order Date:", formattedDate),
                  buildReceiptRow("Order Time:", formattedTime),
                  buildReceiptRow("Payment Method:", paymentMethod),
                  buildReceiptRow("Total Items:", totalItemsCount.toString()),
                  const Divider(height: 30, thickness: 2),
                  const Text(
                    "Items Purchased:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...cartItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.name} (x${item.quantity})",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          "₵${(item.price * item.quantity).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )).toList(),
                  const Divider(height: 30, thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount Paid:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₵${totalOrderPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()), // Corrected: HomeScreen
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Back to Home",
                        style: TextStyle(fontSize: 18),
                      ),
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

  Widget buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}