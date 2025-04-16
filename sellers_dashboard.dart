//
//
// import 'package:flutter/material.dart';
// import 'sellers_post_item.dart';  // Make sure this import is included
// import 'sellers_settings.dart';
// import  'sellers_messages.dart';
// import 'sellers_wallet.dart';
//
//
// class SellerDashboard extends StatefulWidget {
//   @override
//   _SellerDashboardState createState() => _SellerDashboardState();
// }
//
// class _SellerDashboardState extends State<SellerDashboard> {
//   int _selectedIndex = 0;
//   bool _earningsVisible = false;
//   List<Map<String, dynamic>> postedItems = [
//     {
//       'image': 'assets/book.jpg',
//       'name': 'Book',
//       'price': '50.00',
//       'status': 'Available'
//     },
//     {
//       'image': 'assets/sneakers.jpg',
//       'name': 'Sneakers',
//       'price': '80.00',
//       'status': 'Available'
//     },
//   ];
//
//   // void _onItemTapped(int index) {
//   //   setState(() {
//   //     _selectedIndex = index;
//   //   });
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
//   void _toggleEarningsVisibility() {
//     setState(() {
//       _earningsVisible = !_earningsVisible;
//     });
//   }
//
//   void _toggleItemAvailability(int index) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Change'),
//         content: Text('Do you want to mark this item as unavailable?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 postedItems[index]['status'] =
//                 postedItems[index]['status'] == 'Available'
//                     ? 'Unavailable'
//                     : 'Available';
//               });
//               Navigator.pop(context);
//             },
//             child: Text('Yes'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('No'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Add the different screens to navigate between
//   List<Widget> _screens() {
//     return [
//       // Home Screen
//       SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Overview Section with linear gradient
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF004D40), Color(0xFF76FF03)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Overview',
//                       style: TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Total Items Listed: 5',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     SizedBox(height: 8),
//                     GestureDetector(
//                       onTap: _toggleEarningsVisibility,
//                       child: Row(
//                         children: [
//                           Text(
//                             'Total Earnings: ',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           Text(
//                             _earningsVisible ? 'GHS 500.00' : '******',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//                           ),
//                           Icon(
//                             _earningsVisible
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: Colors.white,
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16),
//
//               // Manage Listings Section
//               Text(
//                 'Manage Listings',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               ...List.generate(postedItems.length, (index) {
//                 return Card(
//                   elevation: 5,
//                   margin: EdgeInsets.only(bottom: 16),
//                   child: ListTile(
//                     leading: Image.asset(
//                       postedItems[index]['image'],
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     ),
//                     title: Text(postedItems[index]['name']),
//                     subtitle: Text('Price: GHS ${postedItems[index]['price']}'),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           postedItems[index]['status'],
//                           style: TextStyle(
//                               color: postedItems[index]['status'] == 'Available'
//                                   ? Colors.green
//                                   : Colors.red),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.toggle_on),
//                           onPressed: () => _toggleItemAvailability(index),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//       // Messages Screen
//       Center(child: Text('Messages Screen')),
//       // Settings Screen
//       Center(child: Text('Settings Screen')),
//       // Wallet Screen
//       Center(child: Text('Wallet Screen')),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text('Seller Dashboard'),
//         backgroundColor: Color(0xFF004D40),
//       ),
//       body: _screens()[_selectedIndex], // Display the selected screen
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
//         onPressed: () {
//           // Navigate to the post screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SellerPostItem()),
//           );
//         },
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

import 'package:flutter/material.dart';
import 'sellers_post_item.dart'; // Ensure correct import
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

  List<Map<String, dynamic>> postedItems = [
    {
      'image': 'assets/book.jpg',
      'name': 'Book',
      'price': '50.00',
      'status': 'Available'
    },
    {
      'image': 'assets/sneakers.jpg',
      'name': 'Sneakers',
      'price': '80.00',
      'status': 'Available'
    },
  ];

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellersMessages()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellersSettings()),
        );
        break;
      case 3:
        Navigator.push(
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

  void _toggleItemAvailability(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Change'),
        content: Text('Do you want to mark this item as unavailable?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                postedItems[index]['status'] =
                postedItems[index]['status'] == 'Available'
                    ? 'Unavailable'
                    : 'Available';
              });
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  List<Widget> _screens() {
    return [
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF76FF03)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Items Listed: 5',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _toggleEarningsVisibility,
                      child: Row(
                        children: [
                          Text(
                            'Total Earnings: ',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            _earningsVisible ? 'GHS 500.00' : '******',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Icon(
                            _earningsVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Manage Listings Section
              Text(
                'Manage Listings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...List.generate(postedItems.length, (index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Image.asset(
                      postedItems[index]['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(postedItems[index]['name']),
                    subtitle: Text('Price: GHS ${postedItems[index]['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          postedItems[index]['status'],
                          style: TextStyle(
                            color: postedItems[index]['status'] == 'Available'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.toggle_on),
                          onPressed: () => _toggleItemAvailability(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      Center(child: Text('Messages Screen')),
      Center(child: Text('Settings Screen')),
      Center(child: Text('Wallet Screen')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 This keeps the FAB fixed when keyboard appears

      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Seller Dashboard'),
        backgroundColor: Color(0xFF004D40),
      ),
      body: _screens()[_selectedIndex],
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
              SizedBox(width: 40),
              _buildNavIcon(Icons.settings, 2),
              _buildNavIcon(Icons.account_balance_wallet, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerPostItem()),
          );
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add, size: 30),
        shape: CircleBorder(),
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
