import 'package:flutter/material.dart';
import 'profile_settings.dart';  // Import profile settings screen
import 'manage_listings.dart';  // Import manage listings screen
import 'order_management.dart';  // Import order management screen
import 'sales_overview.dart';  // Import sales overview screen

class SellerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004D40),
        title: Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to profile settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Profile Overview
            Text(
              'Seller Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: Text('Username: Seller123'),
                subtitle: Text('Email: seller@example.com'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // Navigate to profile settings
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileSettingsScreen()),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Active Listings
            Text(
              'Active Listings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Active listing items (You can replace this with dynamic data from Firebase)
            Card(
              child: ListTile(
                title: Text('Item 1 - Laptop'),
                subtitle: Text('Price: GHS 1500'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // Navigate to edit listing screen
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to add new listing screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageListingsScreen()),
                );
              },
              child: Text('Add New Listing'),
            ),
            SizedBox(height: 20),

            // Order Management
            Text(
              'Order Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to order management screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderManagementScreen()),
                );
              },
              child: Text('Manage Orders'),
            ),
            SizedBox(height: 20),

            // Sales Overview
            Text(
              'Sales Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Sales stats (Replace with actual data)
            Card(
              child: ListTile(
                title: Text('Total Sales: GHS 5000'),
                subtitle: Text('Total Earnings: GHS 4000'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to sales overview screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesOverviewScreen()),
                );
              },
              child: Text('View Full Report'),
            ),
          ],
        ),
      ),
    );
  }
}
