
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:UniTrade/models/cart_model.dart'; // Ensure this import is correct
// import 'package:UniTrade/screens/checkout_screen.dart'; // Ensure this import is correct'
//
// class CartScreen extends StatefulWidget {
//   const CartScreen({Key? key}) : super(key: key);
//
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   int _selectedTab = 0; // Default tab index for "All"
//
//   // This method remains for filtering, but 'status' is now simplified for cart items.
//   // Full order status management might be a separate feature/collection.
//   List<Map<String, dynamic>> getFilteredOrders(List<CartItem> cartItems) {
//     List<Map<String, dynamic>> ordersForDisplay = cartItems.map((item) => item.toMapForDisplay()).toList();
//
//     if (_selectedTab == 0) return ordersForDisplay; // "All" tab
//     // For cart items, 'status' is currently always 'Pending' via toMapForDisplay().
//     // If you introduce actual order statuses (e.g., in a separate 'orders' collection),
//     // you'd retrieve them differently.
//     String status = ["All", "Pending", "Cancelled", "Completed"][_selectedTab];
//     return ordersForDisplay.where((order) => order["status"] == status).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CartModel>(
//       builder: (context, cartModel, child) {
//         final List<Map<String, dynamic>> orders =  getFilteredOrders(cartModel.items);
//
//         return Scaffold(
//           backgroundColor: const Color(0xFFD9D9D9),
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // **Navbar (Green Background)**
//               Container(
//                 height: 140,
//                 color: const Color.fromRGBO(0, 77, 64, 1),
//                 padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
//                 child:  SafeArea(
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       // **App Logo on the Left**
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Image.asset('assets/app_logo_white.png', width: 70, height: 70),
//                       ),
//                       // **Centered "Orders" Text**
//                       Text(
//                         "Orders",
//                         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//                       ),
//                       // **More Icon on the Right**
//                       Align(
//                         alignment: Alignment.centerRight,
//                         // child: Icon(Icons.more_vert, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               // **Order Filters (All, Pending, Cancelled, Completed)**
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(4, (index) {
//                   String tabName = ["All", "Pending", "Cancelled", "Completed"][index];
//                   bool isSelected = _selectedTab == index;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedTab = index;
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? (tabName == "Completed" ? Colors.green : Colors.redAccent)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(20),
//                         border: isSelected ? null : Border.all(color: Colors.green, width: 1),
//                       ),
//                       child: Text(
//                         tabName,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : Colors.black26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//
//               const SizedBox(height: 15),
//
//               // **Orders List / Cart Items List**
//               Expanded(
//                 child: orders.isEmpty
//                     ? const Center(child: Text("Your cart is empty."))
//                     : ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     var order = orders[index];
//                     CartItem currentCartItem = cartModel.items.firstWhere(
//                           (item) => item.itemId == order["itemId"],
//                       orElse: () {
//                         // Fallback: This should ideally not happen if data is consistent
//                         print('Error: CartItem not found in in-memory model for itemId: ${order["itemId"]}');
//                         return CartItem(
//                           itemId: order["itemId"] as String,
//                           name: order["item"] as String,
//                           price: double.parse(order["price"] as String),
//                           imageUrl: 'https://via.placeholder.com/150',
//                           sellerId: order["sellerId"] as String? ?? 'unknown',
//                           sellerName: order["seller"] as String? ?? 'Unknown Seller',
//                           paymentMethod: 'Cash',
//                           description: 'Error: Item data missing',
//                           quantity: 0,
//                         );
//                       },
//                     );
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: currentCartItem.imageUrl.isNotEmpty
//                               ? NetworkImage(currentCartItem.imageUrl) as ImageProvider<Object>
//                               : const AssetImage('assets/app_logo.png') as ImageProvider<Object>,
//                           onBackgroundImageError: (exception, stackTrace) {
//                             print('Error loading image for ${currentCartItem.name}: $exception');
//                           },
//                           radius: 25,
//                         ),
//                         title: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Ordered from ${order["seller"]}",
//                               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               "${order["item"]} (x${currentCartItem.quantity})",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//
//                             Text("₵${order["price"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                             Text(order["date"], style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                           ],
//                         ),
//                         trailing: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 // Decrement quantity (removes item if quantity becomes 0)
//                                 IconButton(
//                                   icon: const Icon(Icons.remove_circle_outline, size: 30, color: Colors.red),
//                                   onPressed: () {
//                                     cartModel.decrementItemQuantity(order["itemId"]);
//                                   },
//                                 ),
//                                 // Increment quantity
//                                 IconButton(
//                                   icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.green),
//                                   onPressed: () {
//                                     // When incrementing, ensure you pass ALL necessary properties
//                                     // if the addItem method expects them.
//                                     // The current CartModel's addItem just needs `itemId` to find existing.
//                                     // However, for consistency and future-proofing,
//                                     // pass the full item data.
//                                     cartModel.addItem(currentCartItem.toFirestore()); // Pass as Firestore map, since addItem accepts map
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               // Total Price and Checkout Button section
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Total Items: ${cartModel.totalItemsCount}",
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "Total Price: ₵${cartModel.totalPrice.toStringAsFixed(2)}",
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
//                 child: ElevatedButton(
//                   onPressed: cartModel.items.isEmpty ? null : () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Proceeding to checkout (not implemented yet)!"))
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:UniTrade/models/cart_model.dart'; // This correctly imports CartModel and CartItem

// >>>>>>>>>>>>> FIX THIS LINE <<<<<<<<<<<<<<<<
// REMOVE THE TRAILING APOSTROPHE. It should NOT have a ' at the end.
// It should be:
import 'package:UniTrade/screens/checkout_screen.dart'; // Corrected Import - NO TRAILING APOSTROPHE


class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedTab = 0; // Default tab index for "All"

  // This method remains for filtering, but 'status' is now simplified for cart items.
  // Full order status management might be a separate feature/collection.
  List<Map<String, dynamic>> getFilteredOrders(List<CartItem> cartItems) {
    List<Map<String, dynamic>> ordersForDisplay = cartItems.map((item) => item.toMapForDisplay()).toList();

    if (_selectedTab == 0) return ordersForDisplay; // "All" tab
    // For cart items, 'status' is currently always 'Pending' via toMapForDisplay().
    // If you introduce actual order statuses (e.g., in a separate 'orders' collection),
    // you'd retrieve them differently.
    String status = ["All", "Pending", "Completed"][_selectedTab];
    return ordersForDisplay.where((order) => order["status"] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        final List<Map<String, dynamic>> orders =  getFilteredOrders(cartModel.items);

        return Scaffold(
          backgroundColor: const Color(0xFFD9D9D9),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Navbar (Green Background)**
              Container(
                height: 140,
                color: const Color.fromRGBO(0, 77, 64, 1),
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
                child:  SafeArea(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // **App Logo on the Left**
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset('assets/app_logo_white.png', width: 70, height: 70),
                      ),
                      // **Centered "Orders" Text**
                      Text(
                        "Orders",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      // **More Icon on the Right**
                      Align(
                        alignment: Alignment.centerRight,
                        // child: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // **Order Filters (All, Pending, Cancelled, Completed)**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  String tabName = ["All", "Pending",  "Completed"][index];
                  bool isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (tabName == "Completed" ? Colors.green : Colors.redAccent)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.green, width: 1),
                      ),
                      child: Text(
                        tabName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 15),

              // **Orders List / Cart Items List**
              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text("Your cart is empty."))
                    : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    CartItem currentCartItem = cartModel.items.firstWhere(
                          (item) => item.itemId == order["itemId"],
                      orElse: () {
                        // Fallback: This should ideally not happen if data is consistent
                        print('Error: CartItem not found in in-memory model for itemId: ${order["itemId"]}');
                        return CartItem(
                          itemId: order["itemId"] as String,
                          name: order["item"] as String,
                          price: double.parse(order["price"] as String),
                          imageUrl: 'https://via.placeholder.com/150',
                          sellerId: order["sellerId"] as String? ?? 'unknown',
                          sellerName: order["seller"] as String? ?? 'Unknown Seller',
                          paymentMethod: 'Cash',
                          description: 'Error: Item data missing',
                          quantity: 0,
                        );
                      },
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: currentCartItem.imageUrl.isNotEmpty
                              ? NetworkImage(currentCartItem.imageUrl) as ImageProvider<Object>
                              : const AssetImage('assets/app_logo.png') as ImageProvider<Object>,
                          onBackgroundImageError: (exception, stackTrace) {
                            print('Error loading image for ${currentCartItem.name}: $exception');
                          },
                          radius: 25,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ordered from ${order["seller"]}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${order["item"]} (x${currentCartItem.quantity})",
                              style: const TextStyle(fontSize: 16),
                            ),

                            Text("₵${order["price"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(order["date"], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrement quantity (removes item if quantity becomes 0)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 30, color: Colors.red),
                                  onPressed: () {
                                    cartModel.decrementItemQuantity(order["itemId"]);
                                  },
                                ),
                                // Increment quantity
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.green),
                                  onPressed: () {
                                    // When incrementing, ensure you pass ALL necessary properties
                                    // if the addItem method expects them.
                                    // The current CartModel's addItem just needs `itemId` to find existing.
                                    // However, for consistency and future-proofing,
                                    // pass the full item data.
                                    cartModel.addItem(currentCartItem.toFirestore()); // Pass as Firestore map, since addItem accepts map
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Total Price and Checkout Button section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Items: ${cartModel.totalItemsCount}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Total Price: ₵${cartModel.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                child: ElevatedButton(
                  onPressed: cartModel.items.isEmpty ? null : () {
                    // >>>>>>>>>>>>> UNCOMMENT THIS BLOCK AND REMOVE THE SNACKBAR <<<<<<<<<<<<<<<<
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(cartItems: cartModel.items),
                      ),
                    );
                    // >>>>>>>>>>>>> REMOVE THIS SNACKBAR LINE <<<<<<<<<<<<<<<<
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text("Proceeding to checkout (not implemented yet)!"))
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}