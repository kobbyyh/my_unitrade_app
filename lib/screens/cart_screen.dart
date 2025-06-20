import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:UniTrade/models/cart_model.dart'; // Make sure CartItem is properly defined here
import 'package:UniTrade/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedTab = 0; // Default tab index for "All"

  // This method now intelligently filters the provided list of CartItem objects.
  List<CartItem> getFilteredItems(List<CartItem> currentItemsList) {
    if (_selectedTab == 0) {
      return currentItemsList; // "All" tab: show all items from the passed list
    }

    String statusFilter = ["", "Pending", "Completed"][_selectedTab]; // "All" is index 0, so "" for filter
    return currentItemsList.where((item) => item.status == statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        List<CartItem> itemsToShow;

        // Determine which list to use based on the selected tab
        if (_selectedTab == 2) { // "Completed" tab
          itemsToShow = cartModel.completedOrders;
        } else { // "All" or "Pending" tabs (referencing the active cart)
          itemsToShow = cartModel.items;
        }

        // Apply filtering based on the selected tab to the chosen list
        final List<CartItem> filteredItems = getFilteredItems(itemsToShow);

        // Dynamic empty message
        String emptyMessage;
        if (_selectedTab == 2) {
          emptyMessage = "No completed orders yet.";
        } else {
          emptyMessage = "Your cart is empty.";
        }

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
                      const Text(
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

              // **Order Filters (All, Pending, Completed)**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  String tabName = ["All", "Pending", "Completed"][index];
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
                            ? (tabName == "Completed" ? Colors.green : const Color.fromRGBO(0, 77, 64, 1))
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
                child: filteredItems.isEmpty
                    ? Center(child: Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.black54),))
                    : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final CartItem item = filteredItems[index]; // Direct use of CartItem

                    // Only show modification buttons for items in the active cart (Pending status)
                    final bool isPendingItem = (_selectedTab == 0 || _selectedTab == 1) && item.status == 'Pending';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: item.imageUrl.isNotEmpty
                              ? NetworkImage(item.imageUrl) as ImageProvider<Object>
                              : const AssetImage('assets/app_logo.png') as ImageProvider<Object>,
                          onBackgroundImageError: (exception, stackTrace) {
                            print('Error loading image for ${item.name}: $exception');
                          },
                          radius: 25,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ordered from ${item.sellerName}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${item.name} (x${item.quantity})",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text("₵${(item.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            // Text(item.dateAdded.toLocal().toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 12)), // Display formatted date
                            Text(
                              item.dateAdded, // Simply use the formatted string directly
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            // Display status
                            Text(
                              "Status: ${item.status}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: item.status == 'Completed' ? Colors.green.shade700 : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        trailing: isPendingItem ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrement quantity (removes item if quantity becomes 0)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 30, color: Colors.red),
                                  onPressed: () {
                                    cartModel.decrementItemQuantity(item.itemId);
                                  },
                                ),
                                // Increment quantity
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.green),
                                  onPressed: () {
                                    // Pass the full item data for consistency
                                    cartModel.addItem(item.toFirestore());
                                  },
                                ),
                              ],
                            ),
                          ],
                        ) : null, // No trailing widget for completed orders
                      ),
                    );
                  },
                ),
              ),

              // Total Price and Checkout Button section (only for Pending/All cart view)
              if (_selectedTab == 0 || _selectedTab == 1) // Only show for "All" or "Pending" tabs
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
              if (_selectedTab == 0 || _selectedTab == 1) // Only show for "All" or "Pending" tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                  child: ElevatedButton(
                    onPressed: cartModel.items.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(cartItems: cartModel.items),
                        ),
                      );
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

