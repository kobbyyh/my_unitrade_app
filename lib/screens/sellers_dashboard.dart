//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'sellers_post_item.dart'; // Ensure correct import
// import 'sellers_settings.dart';
// import 'sellers_messages.dart';
// import 'sellers_wallet.dart';
//
// class SellerDashboard extends StatefulWidget {
//   @override
//   _SellerDashboardState createState() => _SellerDashboardState();
// }
//
// class _SellerDashboardState extends State<SellerDashboard> {
//   int _selectedIndex = 0;
//   bool _earningsVisible = false;
//
//   int totalItemsListed = 0;
//   double totalEarnings = 0.0;
//
//   String _sellerName = 'Seller'; // Default name for seller
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerName();
//     fetchSellerData();
//   }
//
//   Future<void> _fetchSellerName() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         String? newSellerName = user.displayName;
//
//         if (newSellerName == null || newSellerName.isEmpty) {
//           DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
//           if (userDoc.exists) {
//             newSellerName = userDoc['fullName'] ?? userDoc['username'];
//           }
//         }
//
//         setState(() {
//           _sellerName = newSellerName ?? user.email?.split('@').first ?? 'Seller';
//         });
//       } catch (e) {
//         print("Error fetching seller name: $e");
//         setState(() {
//           _sellerName = 'Error';
//         });
//       }
//     }
//   }
//
//   void _onItemTapped(int index) async {
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     switch (index) {
//       case 0:
//         break;
//       case 1:
//         await Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellersMessages()),
//         );
//         break;
//       case 2:
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SellersSettings()),
//         );
//         _fetchSellerName();
//         fetchSellerData();
//         break;
//       case 3:
//         await Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellersWallet()),
//         );
//         break;
//     }
//   }
//
//   void _toggleEarningsVisibility() {
//     setState(() {
//       _earningsVisible = !_earningsVisible;
//     });
//   }
//
//   void _toggleItemAvailabilityFirestore(String itemId, bool currentStatus) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Change'),
//         content: Text(
//             'Do you want to mark this item as ${currentStatus ? 'unavailable' : 'available'}?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () async { // Made onPressed async
//               try {
//                 await FirebaseFirestore.instance
//                     // .collection('sellerListings') // Consistently use sellerListings
//                     .collection('items')
//                     .doc(itemId)
//                     .update({'isAvailable': !currentStatus});
//                 Navigator.pop(context); // Close the dialog
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Item availability updated!')),
//                 );
//               } catch (e) {
//                 print("Error updating item availability: $e");
//                 Navigator.pop(context); // Close the dialog
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to update availability. Try again.')),
//                 );
//               }
//             },
//             child: const Text('Yes'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context), // Close the dialog
//             child: const Text('No'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _deleteItemFirestore(String itemId, String itemName) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Deletion'),
//         content: Text(
//             'Are you sure you want to permanently delete "$itemName"? This action cannot be undone.'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context); // Close the dialog first
//               try {
//                 // Delete from Firestore
//                 await FirebaseFirestore.instance
//                     // .collection('sellerListings') // Consistently use sellerListings
//                     .collection('items')
//                     .doc(itemId)
//                     .delete(); // <--- This performs the permanent delete
//
//                 // Show success message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('"$itemName" deleted successfully!')),
//                 );
//                 // Re-fetch seller data to update the total items count (this will update 'totalItemsListed')
//                 fetchSellerData();
//               } catch (e) {
//                 // Show error message
//                 print("Error deleting item: $e");
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to delete "$itemName". Please try again.')),
//                 );
//               }
//             },
//             child: const Text('Delete'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context), // Close the dialog
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Fetch data from Firestore for total items and earnings
//   Future<void> fetchSellerData() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       final itemSnapshot = await FirebaseFirestore.instance
//           // .collection('sellerListings') // Consistently use sellerListings
//           .collection('items')
//           .where('sellerId', isEqualTo: userId)
//           .get();
//
//       double currentTotalEarnings = 0.0;
//       for (var doc in itemSnapshot.docs) {
//         // Ensure you're only counting earnings for items marked as 'isSold'
//         if (doc.data().containsKey('isSold') && doc['isSold'] == true) {
//           final price = doc['price'];
//           if (price is num) {
//             currentTotalEarnings += price.toDouble();
//           }
//         }
//       }
//
//       setState(() {
//         totalItemsListed = itemSnapshot.docs.length;
//         totalEarnings = currentTotalEarnings;
//       });
//     } else {
//       setState(() {
//         totalItemsListed = 0;
//         totalEarnings = 0.0;
//       });
//     }
//   }
//
//   List<Widget> _screens() {
//     return [
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Hello, $_sellerName!',
//                   style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF004D40)),
//                 ),
//                 const SizedBox(height: 16),
//
//                 const Text(
//                   'Manage Listings',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   // .collection('sellerListings') // Consistently use sellerListings
//                   .collection('items')
//                   .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (snapshot.hasError) {
//                   print("StreamBuilder error: ${snapshot.error}");
//                   return Center(child: Text('Error loading items: ${snapshot.error}'));
//                 }
//
//                 if (FirebaseAuth.instance.currentUser == null) {
//                   return const Center(child: Text('Please log in to view your items.'));
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No items posted yet.'));
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final itemDoc = snapshot.data!.docs[index];
//                     final item = itemDoc.data() as Map<String, dynamic>;
//                     final itemId = itemDoc.id; // Get the document ID
//                     final imageUrl = item['imageUrl'] as String?; // Will use the placeholder if no real image
//                     final title = item['title'] as String? ?? 'Untitled Item';
//                     final price = item['price'] as num? ?? 0.0;
//                     final isAvailable = item['isAvailable'] == true;
//
//                     return Card(
//                       elevation: 5,
//                       margin: const EdgeInsets.only(bottom: 16),
//                       child: ListTile(
//                         leading: imageUrl != null && imageUrl.isNotEmpty
//                             ? Image.network(
//                           imageUrl,
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                           const Icon(Icons.broken_image, size: 50),
//                         )
//                             : const Icon(Icons.image_not_supported, size: 50),
//                         title: Text(title),
//                         subtitle: Text('Price: GHS ${price.toStringAsFixed(2)}'),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Availability Toggle
//                             Text(
//                               isAvailable ? 'Available' : 'Unavailable',
//                               style: TextStyle(
//                                 color: isAvailable ? Colors.green : Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 isAvailable ? Icons.toggle_on : Icons.toggle_off,
//                                 color: isAvailable ? Colors.green : Colors.red,
//                                 size: 30,
//                               ),
//                               onPressed: () {
//                                 _toggleItemAvailabilityFirestore(itemId, isAvailable);
//                               },
//                             ),
//                             // DELETE BUTTON
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete_forever, // Delete icon
//                                 color: Colors.grey, // A less alarming color initially
//                                 size: 28,
//                               ),
//                               onPressed: () {
//                                 _deleteItemFirestore(itemId, title); // Pass ID and Title
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       SellersMessages(),
//       SellersSettings(),
//       SellersWallet(),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF004D40),
//         automaticallyImplyLeading: false,
//       ),
//       body: _screens()[_selectedIndex],
//       bottomNavigationBar: BottomAppBar(
//         color: const Color(0xFF004D40),
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 10,
//         child: SizedBox(
//           height: 60,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               _buildNavIcon(Icons.home, 0),
//               _buildNavIcon(Icons.message, 1),
//               const SizedBox(width: 40),
//               _buildNavIcon(Icons.settings, 2),
//               _buildNavIcon(Icons.account_balance_wallet, 3),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SellerPostItem()),
//           );
//           fetchSellerData(); // Re-fetch overview data after posting new item
//           _fetchSellerName();
//         },
//         backgroundColor: Colors.blueGrey,
//         child: const Icon(Icons.add, size: 30),
//         shape: const CircleBorder(),
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
// ------------------CORRECT CODE-----------------------------------------------------
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sellers_post_item.dart';
import 'sellers_settings.dart';
import 'sellers_messages.dart';
import 'sellers_wallet.dart';

class SellerDashboard extends StatefulWidget {
  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _selectedIndex = 0;
  bool _earningsVisible = false;

  int totalItemsListed = 0;
  double totalEarnings = 0.0;

  String _sellerName = 'Seller';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchSellerName();
    fetchSellerData();
  }

  Future<void> _fetchSellerName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String? newSellerName = user.displayName;

        if (newSellerName == null || newSellerName.isEmpty) {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            newSellerName = userDoc['fullName'] ?? userDoc['username'];
          }
        }

        setState(() {
          _sellerName = newSellerName ?? user.email?.split('@').first ?? 'Seller';
        });
      } catch (e) {
        print("Error fetching seller name: $e");
        setState(() {
          _sellerName = 'Error';
        });
      }
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellersMessages()),
        );
        break;
      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellersSettings()),
        );
        _fetchSellerName();
        fetchSellerData();
        break;
      case 3:
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellersWallet()),
        );
        break;
    }
  }

  void _toggleEarningsVisibility() {
    setState(() {
      _earningsVisible = !_earningsVisible;
    });
  }

  void _markItemAsSold(String itemId, double itemPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId)
          .update({'isSold': true});

      setState(() {
        totalEarnings += itemPrice;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item marked as sold!')),
      );
      fetchSellerData(); // Re-fetch data to update total earnings
    } catch (e) {
      print("Error marking item as sold: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark as sold. Try again.')),
      );
    }
  }

  void _deleteItemFirestore(String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to permanently delete "$itemName"? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('items')
                    .doc(itemId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$itemName" deleted successfully!')),
                );
                fetchSellerData();
              } catch (e) {
                print("Error deleting item: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete "$itemName". Please try again.')),
                );
              }
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Fetch data from Firestore for total items and earnings
  Future<void> fetchSellerData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final itemSnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('sellerId', isEqualTo: userId)
          .get();

      double currentTotalEarnings = 0.0;
      for (var doc in itemSnapshot.docs) {
        if (doc.data().containsKey('isSold') && doc['isSold'] == true) {
          final price = doc['price'];
          if (price is num) {
            currentTotalEarnings += price.toDouble();
          }
        }
      }

      setState(() {
        totalItemsListed = itemSnapshot.docs.length;
        totalEarnings = currentTotalEarnings;
      });
    } else {
      setState(() {
        totalItemsListed = 0;
        totalEarnings = 0.0;
      });
    }
  }

  List<Widget> _screens() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_sellerName!',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _toggleEarningsVisibility,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: const Color(0xFFE0F2F1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                              Icon(
                                _earningsVisible ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF004D40),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_earningsVisible) ...[
                            Divider(color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Items Listed:',
                                  style: TextStyle(fontSize: 16, color: Color(0xFF004D40)),
                                ),
                                Text(
                                  '$totalItemsListed',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004D40)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Earnings:',
                                  style: TextStyle(fontSize: 16, color: Color(0xFF004D40)),
                                ),
                                Text(
                                  '₵${totalEarnings.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004D40)),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              'Tap to show details',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Manage Listings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("StreamBuilder error: ${snapshot.error}");
                  return Center(child: Text('Error loading items: ${snapshot.error}'));
                }

                if (FirebaseAuth.instance.currentUser == null) {
                  return const Center(child: Text('Please log in to view your items.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No items posted yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final itemDoc = snapshot.data!.docs[index];
                    final item = itemDoc.data() as Map<String, dynamic>;
                    final itemId = itemDoc.id;
                    final imageUrl = item['imageUrl'] as String?;
                    final title = item['title'] as String? ?? 'Untitled Item';
                    final price = item['price'] as num? ?? 0.0;
                    final isSold = item['isSold'] == true; // Get isSold status

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      // Apply grayscale effect if sold
                      color: isSold ? Colors.grey[300] : null,
                      child: Opacity(
                        opacity: isSold ? 0.6 : 1.0, // Make it slightly transparent
                        child: ListTile(
                          leading: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                          )
                              : const Icon(Icons.image_not_supported, size: 50),
                          title: Text(
                            title,
                            style: TextStyle(
                              decoration: isSold ? TextDecoration.lineThrough : TextDecoration.none, // Strikethrough if sold
                            ),
                          ),
                          subtitle: Text('Price: ₵${price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // "Sold" Button
                              IconButton(
                                icon: Icon(
                                  Icons.shopping_cart_checkout,
                                  color: isSold ? Colors.grey : Colors.green, // Gray out if sold
                                  size: 30,
                                ),
                                onPressed: isSold // Disable button if sold
                                    ? null
                                    : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Item Sold?'),
                                      content: const Text('Have you sold this item?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); // Close dialog
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); // Close dialog
                                            _markItemAsSold(itemId, price.toDouble());
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: isSold ? Colors.grey : Colors.grey, // Gray out if sold
                                  size: 28,
                                ),
                                onPressed: isSold // Disable delete button if sold
                                    ? null
                                    : () {
                                  _deleteItemFirestore(itemId, title);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      SellersMessages(),
      SellersSettings(),
      SellersWallet(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),
      body: _screens()[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF004D40),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.home, 0),
              _buildNavIcon(Icons.message, 1),
              const SizedBox(width: 40),
              _buildNavIcon(Icons.settings, 2),
              _buildNavIcon(Icons.account_balance_wallet, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerPostItem()),
          );
          fetchSellerData();
          _fetchSellerName();
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, size: 30),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.white70,
        size: 30,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}

















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'sellers_post_item.dart';
// import 'sellers_settings.dart';
// import 'sellers_messages.dart';
// import 'sellers_wallet.dart';
//
// class SellerDashboard extends StatefulWidget {
//   @override
//   _SellerDashboardState createState() => _SellerDashboardState();
// }
//
// class _SellerDashboardState extends State<SellerDashboard> {
//   int _selectedIndex = 0;
//   bool _earningsVisible = false; // Controls visibility of earnings details
//
//   int totalItemsListed = 0;
//   double totalEarnings = 0.0;
//
//   String _sellerName = 'Seller';
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerName();
//     fetchSellerData();
//   }
//
//   Future<void> _fetchSellerName() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         String? newSellerName = user.displayName;
//
//         if (newSellerName == null || newSellerName.isEmpty) {
//           DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
//           if (userDoc.exists) {
//             newSellerName = userDoc['fullName'] ?? userDoc['username'];
//           }
//         }
//
//         setState(() {
//           _sellerName = newSellerName ?? user.email?.split('@').first ?? 'Seller';
//         });
//       } catch (e) {
//         print("Error fetching seller name: $e");
//         setState(() {
//           _sellerName = 'Error';
//         });
//       }
//     }
//   }
//
//   void _onItemTapped(int index) async {
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     switch (index) {
//       case 0:
//       // Dashboard tab, no navigation needed
//         break;
//       case 1:
//         await Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellersMessages()),
//         );
//         break;
//       case 2:
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SellersSettings()),
//         );
//         // Refresh data after returning from settings
//         _fetchSellerName();
//         fetchSellerData();
//         break;
//       case 3:
//         await Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellersWallet()),
//         );
//         break;
//     }
//   }
//
//   void _toggleEarningsVisibility() {
//     setState(() {
//       _earningsVisible = !_earningsVisible;
//     });
//   }
//
//   void _toggleItemAvailabilityFirestore(String itemId, bool currentStatus) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Change'),
//         content: Text(
//             'Do you want to mark this item as ${currentStatus ? 'unavailable' : 'available'}?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () async {
//               try {
//                 await FirebaseFirestore.instance
//                     .collection('items') // Assumed correct collection path
//                     .doc(itemId)
//                     .update({'isAvailable': !currentStatus});
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Item availability updated!')),
//                 );
//               } catch (e) {
//                 print("Error updating item availability: $e");
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Failed to update availability. Try again.')),
//                 );
//               }
//             },
//             child: const Text('Yes'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('No'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _deleteItemFirestore(String itemId, String itemName) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Deletion'),
//         content: Text(
//             'Are you sure you want to permanently delete "$itemName"? This action cannot be undone.'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               try {
//                 await FirebaseFirestore.instance
//                     .collection('items') // Assumed correct collection path
//                     .doc(itemId)
//                     .delete();
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('"$itemName" deleted successfully!')),
//                 );
//                 fetchSellerData();
//               } catch (e) {
//                 print("Error deleting item: $e");
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to delete "$itemName". Please try again.')),
//                 );
//               }
//             },
//             child: const Text('Delete'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> fetchSellerData() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       final itemSnapshot = await FirebaseFirestore.instance
//           .collection('items') // Assumed correct collection path
//           .where('sellerId', isEqualTo: userId)
//           .get();
//
//       double currentTotalEarnings = 0.0;
//       for (var doc in itemSnapshot.docs) {
//         if (doc.data().containsKey('isSold') && doc['isSold'] == true) {
//           final price = doc['price'];
//           if (price is num) {
//             currentTotalEarnings += price.toDouble();
//           }
//         }
//       }
//
//       setState(() {
//         totalItemsListed = itemSnapshot.docs.length;
//         totalEarnings = currentTotalEarnings;
//       });
//     } else {
//       setState(() {
//         totalItemsListed = 0;
//         totalEarnings = 0.0;
//       });
//     }
//   }
//
//   List<Widget> _screens() {
//     return [
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Hello, $_sellerName!',
//                   style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF004D40)),
//                 ),
//                 const SizedBox(height: 16),
//                 // Earnings Summary Card
//                 GestureDetector(
//                   onTap: _toggleEarningsVisibility,
//                   child: Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     color: const Color(0xFFE0F2F1), // Light teal background
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Overview',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF004D40),
//                                 ),
//                               ),
//                               Icon(
//                                 _earningsVisible ? Icons.visibility_off : Icons.visibility,
//                                 color: Color(0xFF004D40),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           if (_earningsVisible) ...[
//                             Divider(color: Colors.grey[400]),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Total Items Listed:',
//                                   style: TextStyle(fontSize: 16, color: Color(0xFF004D40)),
//                                 ),
//                                 Text(
//                                   '$totalItemsListed',
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF004D40)),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Total Earnings:',
//                                   style: TextStyle(fontSize: 16, color: Color(0xFF004D40)),
//                                 ),
//                                 Text(
//                                   '₵${totalEarnings.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF004D40)),
//                                 ),
//                               ],
//                             ),
//                           ] else ...[
//                             // Placeholder when earnings are hidden
//                             Text(
//                               'Tap to show details',
//                               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Manage Listings',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('items') // Assumed correct collection path
//                   .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (snapshot.hasError) {
//                   print("StreamBuilder error: ${snapshot.error}");
//                   return Center(child: Text('Error loading items: ${snapshot.error}'));
//                 }
//
//                 if (FirebaseAuth.instance.currentUser == null) {
//                   return const Center(child: Text('Please log in to view your items.'));
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No items posted yet.'));
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final itemDoc = snapshot.data!.docs[index];
//                     final item = itemDoc.data() as Map<String, dynamic>;
//                     final itemId = itemDoc.id;
//                     final imageUrl = item['imageUrl'] as String?;
//                     final title = item['title'] as String? ?? 'Untitled Item';
//                     final price = item['price'] as num? ?? 0.0;
//                     final isAvailable = item['isAvailable'] == true;
//
//                     return Card(
//                       elevation: 5,
//                       margin: const EdgeInsets.only(bottom: 16),
//                       child: ListTile(
//                         leading: imageUrl != null && imageUrl.isNotEmpty
//                             ? Image.network(
//                           imageUrl,
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                           const Icon(Icons.broken_image, size: 50),
//                         )
//                             : const Icon(Icons.image_not_supported, size: 50),
//                         title: Text(title),
//                         subtitle: Text('Price: GHS ${price.toStringAsFixed(2)}'),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               isAvailable ? 'Available' : 'Unavailable',
//                               style: TextStyle(
//                                 color: isAvailable ? Colors.green : Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 isAvailable ? Icons.toggle_on : Icons.toggle_off,
//                                 color: isAvailable ? Colors.green : Colors.red,
//                                 size: 30,
//                               ),
//                               onPressed: () {
//                                 _toggleItemAvailabilityFirestore(itemId, isAvailable);
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete_forever,
//                                 color: Colors.grey,
//                                 size: 28,
//                               ),
//                               onPressed: () {
//                                 _deleteItemFirestore(itemId, title);
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       SellersMessages(),
//       SellersSettings(),
//       SellersWallet(),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF004D40),
//         automaticallyImplyLeading: false,
//       ),
//       body: _screens()[_selectedIndex],
//       bottomNavigationBar: BottomAppBar(
//         color: const Color(0xFF004D40),
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 10,
//         child: SizedBox(
//           height: 60,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               _buildNavIcon(Icons.home, 0),
//               _buildNavIcon(Icons.message, 1),
//               const SizedBox(width: 40),
//               _buildNavIcon(Icons.settings, 2),
//               _buildNavIcon(Icons.account_balance_wallet, 3),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SellerPostItem()),
//           );
//           fetchSellerData();
//           _fetchSellerName();
//         },
//         backgroundColor: Colors.blueGrey,
//         child: const Icon(Icons.add, size: 30),
//         shape: const CircleBorder(),
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



