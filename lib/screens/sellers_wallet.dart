

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'sellers_post_item.dart';
// import 'sellers_settings.dart';
// import 'sellers_messages.dart';
// import 'sellers_dashboard.dart';
//
// class SellersWallet extends StatefulWidget {
//   @override
//   _SellersWalletState createState() => _SellersWalletState();
// }
//
// class _SellersWalletState extends State<SellersWallet> {
//   bool isBalanceVisible = true;
//   bool isEarningsVisible = true;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? _currentSellerUser;
//
//   // State variables for overview data - THESE ARE HERE ONLY
//   int totalItemsListed = 0;
//   int totalItemsAvailable = 0;
//   int totalItemsSold = 0;
//   int totalItemsRemoved = 0;
//   double totalEarnings = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentSellerUser = _auth.currentUser;
//     _fetchSellerOverviewData(); // Fetch the new overview data in Wallet
//   }
//
//   Future<void> _fetchSellerOverviewData() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       try {
//         // Change collection name from 'items' to 'sellerListings'
//         final QuerySnapshot allItemsSnapshot = await _firestore
//             .collection('items') // <--- CHANGED HERE
//             // .collection('sellerListings')
//             .where('sellerId', isEqualTo: userId)
//             .get();
//
//         int currentTotalItemsListed = 0;
//         int currentTotalItemsAvailable = 0;
//         int currentTotalItemsSold = 0;
//         int currentTotalItemsRemoved = 0;
//         double currentTotalEarnings = 0.0;
//
//         for (var doc in allItemsSnapshot.docs) {
//           final itemData = doc.data() as Map<String, dynamic>;
//           currentTotalItemsListed++;
//
//           bool isAvailable = itemData['isAvailable'] == true;
//           bool isSold = itemData['isSold'] == true;
//           bool isRemoved = itemData['isRemoved'] == true;
//
//           if (isAvailable) {
//             currentTotalItemsAvailable++;
//           }
//           if (isSold) {
//             currentTotalItemsSold++;
//             final price = itemData['price'];
//             if (price is num) {
//               currentTotalEarnings += price.toDouble();
//             }
//           }
//           if (isRemoved) {
//             currentTotalItemsRemoved++;
//           }
//         }
//
//         setState(() {
//           totalItemsListed = currentTotalItemsListed;
//           totalItemsAvailable = currentTotalItemsAvailable;
//           totalItemsSold = currentTotalItemsSold;
//           totalItemsRemoved = currentTotalItemsRemoved;
//           totalEarnings = currentTotalEarnings;
//         });
//       } catch (e) {
//         print("Error fetching seller overview data: $e");
//       }
//     }
//   }
//
//   int _selectedIndex = 3;
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellerDashboard()),
//         );
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellersMessages()),
//         );
//         break;
//       case 2:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellersSettings()),
//         );
//         break;
//       case 3:
//         _fetchSellerOverviewData();
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_currentSellerUser == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Wallet"),
//           backgroundColor: const Color(0xFF004D40),
//           automaticallyImplyLeading: false,
//         ),
//         body: const Center(
//           child: Text('Please log in to view your wallet.'),
//         ),
//         bottomNavigationBar: _buildSellerBottomNavBar(),
//         floatingActionButton: _buildFloatingActionButton(),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       );
//     }
//
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Your Wallet"),
//         backgroundColor: const Color(0xFF004D40),
//         automaticallyImplyLeading: false,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             StreamBuilder<DocumentSnapshot>(
//               stream: _firestore.collection('users').doc(_currentSellerUser!.uid).snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Card(
//                     elevation: 6,
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     child: const Padding(
//                       padding: EdgeInsets.all(24.0),
//                       child: Center(child: CircularProgressIndicator(color: Color(0xFF004D40))),
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   print("Error fetching balance: ${snapshot.error}");
//                   return Card(
//                     elevation: 6,
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
//                     ),
//                   );
//                 }
//
//                 double currentBalance = (snapshot.data?.data() as Map<String, dynamic>?)?['walletBalance'] ?? 0.0;
//
//                 return Card(
//                   elevation: 6,
//                   color: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("Current Balance", style: TextStyle(fontSize: 18, color: Colors.grey)),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Text(
//                                 isBalanceVisible ? "GHS ${currentBalance.toStringAsFixed(2)}" : "******",
//                                 style: const TextStyle(
//                                   fontSize: 48,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF004D40),
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 isBalanceVisible ? Icons.visibility_off : Icons.visibility,
//                                 color: Color(0xFF004D40),
//                                 size: 30,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   isBalanceVisible = !isBalanceVisible;
//                                 });
//                               },
//                             )
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             const SizedBox(height: 25),
//
//             // MOVED & ENHANCED OVERVIEW SECTION
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF004D40),
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 7,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Your Performance Overview',
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   const Divider(color: Colors.white54, height: 20, thickness: 1),
//                   _buildOverviewRow('Total Items Listed:', totalItemsListed.toString()),
//                   _buildOverviewRow('Total Items Available:', totalItemsAvailable.toString()),
//                   _buildOverviewRow('Total Items Sold:', totalItemsSold.toString()),
//                   _buildOverviewRow('Items Removed:', totalItemsRemoved.toString()),
//                   const SizedBox(height: 15),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isEarningsVisible = !isEarningsVisible;
//                       });
//                     },
//                     child: Row(
//                       children: [
//                         const Text(
//                           'Overall Earnings:',
//                           style: TextStyle(color: Colors.white, fontSize: 17),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           isEarningsVisible ? 'GHS ${totalEarnings.toStringAsFixed(2)}' : '******',
//                           style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF76FF03)),
//                         ),
//                         Icon(
//                           isEarningsVisible
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                           color: Colors.white,
//                           size: 20,
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildSellerBottomNavBar(),
//       floatingActionButton: _buildFloatingActionButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Widget _buildOverviewRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(color: Colors.white, fontSize: 17),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFloatingActionButton() {
//     return FloatingActionButton(
//       onPressed: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SellerPostItem()),
//         );
//         _fetchSellerOverviewData(); // Refresh data after posting a new item
//       },
//       backgroundColor: Colors.blueGrey,
//       child: const Icon(Icons.add, size: 30, color: Colors.white),
//       shape: const CircleBorder(),
//     );
//   }
//
//   Widget _buildSellerBottomNavBar() {
//     return BottomAppBar(
//       color: const Color(0xFF004D40),
//       shape: const CircularNotchedRectangle(),
//       notchMargin: 10,
//       child: SizedBox(
//         height: 60,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: <Widget>[
//             _buildNavIcon(Icons.home, 0),
//             _buildNavIcon(Icons.message, 1),
//             const SizedBox(width: 40),
//             _buildNavIcon(Icons.settings, 2),
//             _buildNavIcon(Icons.account_balance_wallet, 3),
//           ],
//         ),
//       ),
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




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sellers_post_item.dart';
import 'sellers_settings.dart';
import 'sellers_messages.dart';
import 'sellers_dashboard.dart';

class SellersWallet extends StatefulWidget {
  @override
  _SellersWalletState createState() => _SellersWalletState();
}

class _SellersWalletState extends State<SellersWallet> {
  bool isBalanceVisible = true; // This will now control visibility for totalEarnings
  // bool isEarningsVisible is now redundant as it controls the same value

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentSellerUser;

  // State variables for overview data - these are now the source for "Current Balance"
  int totalItemsListed = 0;
  int totalItemsAvailable = 0;
  int totalItemsSold = 0;
  int totalItemsRemoved = 0;
  double totalEarnings = 0.0; // This will be the amount displayed as "Current Balance"

  @override
  void initState() {
    super.initState();
    _currentSellerUser = _auth.currentUser;
    _fetchSellerOverviewData(); // Fetch data that includes totalEarnings
  }

  Future<void> _fetchSellerOverviewData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final QuerySnapshot allItemsSnapshot = await _firestore
            .collection('items')
            .where('sellerId', isEqualTo: userId)
            .get();

        int currentTotalItemsListed = 0;
        int currentTotalItemsAvailable = 0;
        int currentTotalItemsSold = 0;
        int currentTotalItemsRemoved = 0;
        double currentTotalEarnings = 0.0; // Recalculate based on 'isSold' items

        for (var doc in allItemsSnapshot.docs) {
          final itemData = doc.data() as Map<String, dynamic>;
          currentTotalItemsListed++;

          bool isAvailable = itemData['isAvailable'] == true;
          bool isSold = itemData['isSold'] == true;
          bool isRemoved = itemData['isRemoved'] == true; // Assuming 'isRemoved' exists

          if (isAvailable) {
            currentTotalItemsAvailable++;
          }
          if (isSold) {
            currentTotalItemsSold++;
            final price = itemData['price'];
            if (price is num) {
              currentTotalEarnings += price.toDouble();
            }
          }
          if (isRemoved) {
            currentTotalItemsRemoved++;
          }
        }

        setState(() {
          totalItemsListed = currentTotalItemsListed;
          totalItemsAvailable = currentTotalItemsAvailable;
          totalItemsSold = currentTotalItemsSold;
          totalItemsRemoved = currentTotalItemsRemoved;
          totalEarnings = currentTotalEarnings; // Update totalEarnings state
        });
      } catch (e) {
        print("Error fetching seller overview data: $e");
        setState(() {
          // Reset if error
          totalItemsListed = 0;
          totalItemsAvailable = 0;
          totalItemsSold = 0;
          totalItemsRemoved = 0;
          totalEarnings = 0.0;
        });
      }
    } else {
      setState(() {
        // Reset if no user
        totalItemsListed = 0;
        totalItemsAvailable = 0;
        totalItemsSold = 0;
        totalItemsRemoved = 0;
        totalEarnings = 0.0;
      });
    }
  }

  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellerDashboard()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellersMessages()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellersSettings()),
        );
        break;
      case 3:
        _fetchSellerOverviewData(); // Refresh data when Wallet tab is tapped
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSellerUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Wallet"),
          backgroundColor: const Color(0xFF004D40),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Please log in to view your wallet.'),
        ),
        bottomNavigationBar: _buildSellerBottomNavBar(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Your Wallet"),
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MODIFIED: Replaced StreamBuilder with direct use of totalEarnings
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Overall Earnings", style: TextStyle(fontSize: 18, color: Colors.grey)), // Changed label
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            isBalanceVisible ? "GHS ${totalEarnings.toStringAsFixed(2)}" : "******",
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004D40),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isBalanceVisible ? Icons.visibility_off : Icons.visibility,
                            color: Color(0xFF004D40),
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              isBalanceVisible = !isBalanceVisible;
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Performance Overview Section (remains largely the same, now mirrors the top display)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Performance Overview',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Divider(color: Colors.white54, height: 20, thickness: 1),
                  _buildOverviewRow('Total Items Listed:', totalItemsListed.toString()),
                  _buildOverviewRow('Total Items Available:', totalItemsAvailable.toString()),
                  _buildOverviewRow('Total Items Sold:', totalItemsSold.toString()),
                  _buildOverviewRow('Items Removed:', totalItemsRemoved.toString()),
                  const SizedBox(height: 15),
                  GestureDetector( // This GestureDetector is now redundant, consider removing or re-purposing
                    onTap: () {
                      setState(() {
                        // This toggle now controls the visibility of 'Overall Earnings' here
                        // but the main balance visibility is controlled by isBalanceVisible
                        // It's probably better to unify these two toggles.
                        isBalanceVisible = !isBalanceVisible; // Unified toggle
                      });
                    },
                    child: Row(
                      children: [
                        const Text(
                          'Overall Earnings:', // Now just a label, value comes from totalEarnings
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBalanceVisible ? 'GHS ${totalEarnings.toStringAsFixed(2)}' : '******', // Unified visibility
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF76FF03)),
                        ),
                        Icon(
                          isBalanceVisible // Unified icon
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildSellerBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellerPostItem()),
        );
        _fetchSellerOverviewData(); // Refresh data after posting a new item
      },
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.add, size: 30, color: Colors.white),
      shape: const CircleBorder(),
    );
  }

  Widget _buildSellerBottomNavBar() {
    return BottomAppBar(
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