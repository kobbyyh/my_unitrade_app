
import 'package:Uni_Trade/screens/cart_screen.dart';
import 'package:Uni_Trade/screens/chat_page.dart';
import 'package:Uni_Trade/screens/settings_page.dart';
import 'package:Uni_Trade/screens/wallet_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track selected tab

  final List<Widget> _screens = [
    HomeContent(),
    CartScreen(),
    MessagesScreen(),
    WalletScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // **Custom Header with increased height**
          // Show navbar only on the Home screen
          if (_selectedIndex == 0 )
            Container(
              height: 140,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Color(0xFF004D40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/app_logo_white.png', width: 70, height: 70), // App logo
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/user-profile.jpg'), // Profile image
                    radius: 30,
                  ),
                ],
              ),
            ),

          // Container(
          //   height: 140, // Increased height for better visibility
          //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          //   decoration: BoxDecoration(
          //     color: Color(0xFF004D40),
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(0),
          //       bottomRight: Radius.circular(0),
          //     ),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Image.asset('assets/app_logo_white.png', width: 70, height: 70,), // App logo
          //       CircleAvatar(
          //         backgroundImage: AssetImage('assets/user-profile.jpg'), // Profile image
          //         radius: 30, // Enlarged profile image
          //       ),
          //     ],
          //   ),
          // ),

          // **Main Content Area**
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),

      // **Bottom Navigation Bar**
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF004D40),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

// **Home Content Section**
class HomeContent extends StatelessWidget {
  final List<String> categories = [
    "Food & Beverages",
    "Clothing",
    "Accessories",
    "Gadgets & Electronics",
    "Personal Care & Beauty",
    "Books & Stationery"
  ];

  final List<Map<String, String>> items = List.generate(20, (index) {
    return {
      "image": "assets/tshirt.jpg",
      "title": "Item ${index + 1}",
      "price": "Ghc ${(index + 1) * 10}.00",
      "seller": "Seller ${index + 1}"
    };
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Search Bar & Filter Button**
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for items...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.filter_list, size: 30),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 15),

          // **Category Scroller**
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color(0xFF004D40)),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(categories[index]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 15),

          // **Product Grid View**
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: List.generate(5, (rowIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 180,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(7, (colIndex) {
                            int itemIndex = rowIndex * 7 + colIndex;
                            if (itemIndex >= items.length) return SizedBox();
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                width: 150,
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                        child: Image.asset(
                                          items[itemIndex]["image"]!,
                                          height: 80,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(items[itemIndex]["title"]!,
                                                style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(items[itemIndex]["price"]!,
                                                style: TextStyle(color: Colors.green)),
                                            Row(
                                              children: [
                                                Icon(Icons.person, size: 14, color: Colors.grey),
                                                SizedBox(width: 5),
                                                Text(items[itemIndex]["seller"]!,
                                                    style: TextStyle(color: Colors.grey)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
