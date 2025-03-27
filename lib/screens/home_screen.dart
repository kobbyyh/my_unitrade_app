import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    "Food & Beverages",
    "Clothing",
    "Accessories",
    "Gadgets & Electronics",
    "Personal Care & Beauty",
    "Books & Stationery"
  ];

  // Sample items list
  final List<Map<String, String>> items = List.generate(20, (index) {
    return {
      "image": "assets/item_placeholder.png", // Replace with actual image paths
      "title": "Item ${index + 1}",
      "price": "Ghc ${(index + 1) * 10}.00",
      "seller": "Seller ${index + 1}"
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004D40), // Teal color
        title: Row(
          children: [
            Image.asset('assets/app_logo_white.png', width: 40, height: 40),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar & Filter Icon
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

            // Horizontal Scrollable Categories
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

            // Scrollable Grid with Horizontal Scrolling Rows
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Ensures vertical scrolling
                child: Column(
                  children: List.generate(5, (rowIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        height: 180, // Row height
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Each row scrolls sideways
                          child: Row(
                            children: List.generate(7, (colIndex) {
                              int itemIndex = rowIndex * 7 + colIndex;
                              if (itemIndex >= items.length) return SizedBox();
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: SizedBox(
                                  width: 150, // Adjust width of each item
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
      ),
    );
  }
}
