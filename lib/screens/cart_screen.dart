
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedTab = 0; // Default tab index for "All"

  final List<Map<String, dynamic>> orders = [
    {
      "seller": "Alexander Acheampong",
      "item": "Bullmers classic T-shirt",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Completed"
    },
    {
      "seller": "Alexander Acheampong",
      "item": "Chromebook",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Pending"
    },
    {
      "seller": "Alexander Acheampong",
      "item": "A1 Bread",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Cancelled"
    },
    {
      "seller": "Alexander Acheampong",
      "item": "Nike Air Force 1",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Completed"
    },
    {
      "seller": "Alexander Acheampong",
      "item": "CeraVe cream",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Pending"
    },
    {
      "seller": "Alexander Acheampong",
      "item": "Egg",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Completed"
    },
    {
      "seller": "Alexander Acheampong",
      "item": "Jeans Trouser",
      "date": "03 March 2025",
      "price": "₵25.00",
      "status": "Cancelled"
    },
  ];

  List<Map<String, dynamic>> getFilteredOrders() {
    if (_selectedTab == 0) return orders; // All Orders
    String status = ["All", "Pending", "Cancelled", "Completed"][_selectedTab];
    return orders.where((order) => order["status"] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xD9D9D9), // Background color

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            color: Color.fromRGBO(0, 77, 64, 1), // Green navbar background
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            child: Stack(
              alignment: Alignment.center, // Centers "Orders"
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
                  child: Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),

          // **Navbar (Green Background)**
          // Container(
          //   color: Color.fromRGBO(0, 77, 64, 1), // Green navbar background
          //   padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 40.0),
          //   child: Stack(
          //     alignment: Alignment.center, // Centers only "Orders"
          //     children: [
          //       Align(
          //         alignment: Alignment.centerLeft,
          //         child: Image.asset('assets/app_logo_white.png', width: 70, height: 70), // App logo
          //       ),
          //       Text(
          //         "Orders",
          //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          //       ),
          //     ],
          //   ),
          // ),

          SizedBox(height: 10),

          // **Order Filters**
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              String tabName = ["All", "Pending", "Cancelled", "Completed"][index];
              bool isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                      color: isSelected ? Colors.black : Colors.black26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 15),

          // **Orders List**
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredOrders().length,
              itemBuilder: (context, index) {
                var order = getFilteredOrders()[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/app_logo.png'),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ordered from ${order["seller"]}",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(order["item"], style: TextStyle(fontSize: 16)),
                        Text(order["date"], style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(order["price"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue),
                            SizedBox(width: 3),
                            Text("Details", style: TextStyle(color: Colors.blue, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
