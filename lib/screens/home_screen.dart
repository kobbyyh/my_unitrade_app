

import 'package:UniTrade/screens/chat_page.dart';
import 'package:UniTrade/screens/settings_page.dart';
import 'package:UniTrade/screens/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:UniTrade/screens/product_detail_screen.dart';
import 'cart_screen.dart' show CartScreen;
import 'package:UniTrade/screens/chat_screen.dart';
import 'package:UniTrade/screens/wallet_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? _currentUser;
  String _userName = 'Guest';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['fullName'] ?? userDoc['username'] ?? 'User';
          });
        }
      } catch (e) {
        print("Error fetching user name: $e");
        setState(() {
          _userName = 'Error';
        });
      }
    }
  }

  final List<Widget> _screens =  [
    HomeContent(),
    CartScreen(),
    MessagesScreen(),
    SettingsScreen(),
    // WalletScreen(), //removed for now
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
          if (_selectedIndex == 0)
            Container(
              height: 140,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF004D40),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/app_logo_white.png', width: 70, height: 70),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'yo, $_userName!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF004D40),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          // BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),

        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _showCategories = false;

  // --- NEW: State variable for selected category ---
  String? _selectedCategory; // Null means no category filter applied

  final List<String> categories = const [
    "Food & Beverages",
    "Clothing",
    "Accessories",
    "Gadgets & Electronics",
    "Personal Care & Beauty",
    "Books & Stationery"
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _toggleCategoriesVisibility() {
    setState(() {
      _showCategories = !_showCategories;
    });
  }

  // --- NEW: Method to handle category selection ---
  void _selectCategory(String category) {
    setState(() {
      // If the same category is clicked again, deselect it (toggle off)
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search for items...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.filter_list, size: 30),
                onPressed: _toggleCategoriesVisibility,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // --- Conditional rendering for Category Scroller ---
          if (_showCategories)
            Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final String currentCategory = categories[index];
                      final bool isSelected = _selectedCategory == currentCategory;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // --- NEW: Conditional styling for selected tab ---
                            backgroundColor: isSelected
                                ? const Color(0xFF004D40) // Green when selected
                                : Colors.white, // White when not selected
                            foregroundColor: isSelected
                                ? Colors.white // White text when selected
                                : Colors.black, // Black text when not selected
                            // --- END NEW ---
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF004D40) : Colors.grey, // Green border for selected, grey for others
                              ),
                            ),
                          ),
                          onPressed: () => _selectCategory(currentCategory), // NEW: Call _selectCategory
                          child: Text(currentCategory),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),

          // **Product Grid View (Now fetches from Firestore and filters)**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: () {
                Query<Map<String, dynamic>> query = FirebaseFirestore.instance
                    .collection('items')
                    .where('isAvailable', isEqualTo: true)
                    .where('isSold', isEqualTo: false);

                // --- NEW: Apply category filter to the query ---
                if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
                  query = query.where('category', isEqualTo: _selectedCategory);
                }
                // --- END NEW ---

                return query.orderBy('timestamp', descending: true).snapshots();
              }(), // Call the function to get the stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("Error fetching items: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Check if there are no items after category filter
                  if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
                    return Center(child: Text('No items found in "${_selectedCategory}" category.'));
                  }
                  return const Center(child: Text('No items available yet.'));
                }

                List<Map<String, dynamic>> items = snapshot.data!.docs.map((doc) {
                  return {...doc.data() as Map<String, dynamic>, 'itemId': doc.id};
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  items = items.where((item) {
                    final title = (item['title'] as String? ?? '').toLowerCase();
                    final description = (item['description'] as String? ?? '').toLowerCase();
                    final searchQueryLower = _searchQuery.toLowerCase();

                    return title.contains(searchQueryLower) || description.contains(searchQueryLower);
                  }).toList();
                }

                if (items.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(child: Text('No items found matching your search.'));
                } else if (items.isEmpty) {
                  return const Center(child: Text('No items available yet.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final imageUrl = item['imageUrl'] as String?;
                    final title = item['title'] as String? ?? 'Untitled Item';
                    final price = item['price'] as num? ?? 0.0;
                    final sellerId = item['sellerId'] as String?;
                    final paymentMethod = item['paymentMethod'] as String? ?? 'Momo';
                    final description = item['description'] as String? ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productData: {
                                'itemId': item['itemId'],
                                'name': title,
                                'price': price,
                                'imageUrl': imageUrl,
                                'sellerId': sellerId,
                                'paymentMethod': paymentMethod,
                                'description': description,
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                              )
                                  : Container(
                                height: 100,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ghc ${price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: sellerId != null && sellerId.isNotEmpty ? FirebaseFirestore.instance.collection('users').doc(sellerId).get() : null,
                                    builder: (context, sellerSnapshot) {
                                      String displaySeller = 'Unknown Seller';
                                      if (sellerSnapshot.connectionState == ConnectionState.done && sellerSnapshot.hasData && sellerSnapshot.data!.exists) {
                                        final Map<String, dynamic> sellerData = sellerSnapshot.data!.data() as Map<String, dynamic>;
                                        displaySeller = sellerData['fullName'] ?? sellerData['username'] ?? 'Unknown Seller';
                                      } else if (sellerId == null || sellerId.isEmpty) {
                                        displaySeller = 'No Seller ID';
                                      }
                                      return Row(
                                        children: [
                                          const Icon(Icons.person, size: 14, color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              displaySeller,
                                              style: const TextStyle(color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}