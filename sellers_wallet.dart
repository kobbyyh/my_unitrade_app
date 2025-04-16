

import 'package:flutter/material.dart';
import 'sellers_post_item.dart';  // Make sure this import is included
import 'sellers_settings.dart';
import  'sellers_messages.dart';
import 'sellers_wallet.dart';
import 'sellers_dashboard.dart';

class SellersWallet extends StatefulWidget {
  @override
  _SellersWalletState createState() => _SellersWalletState();
}

class _SellersWalletState extends State<SellersWallet> {
  double balance = 1200.50; // Example balance, replace with Firebase value
  bool isBalanceVisible = true; // Toggle visibility of balance

  final TextEditingController withdrawController = TextEditingController();

  // Example transaction history data
  final List<Map<String, dynamic>> transactions = [
    {"date": "2025-04-09", "description": "Sale of Laptop", "amount": 300.00, "status": "Completed"},
    {"date": "2025-04-08", "description": "Sale of Phone", "amount": 150.00, "status": "Completed"},
    {"date": "2025-04-07", "description": "Refund", "amount": 50.00, "status": "Pending"},
  ];

  int _selectedIndex = 3; // Set to 3 since this is the Wallet screen

  final List<Widget> _pages = [
    Center(child: Text("Home", style: TextStyle(fontSize: 22))),
    Center(child: Text("Messages", style: TextStyle(fontSize: 22))),
    Center(child: Text("Settings", style: TextStyle(fontSize: 22))),
    Center(child: Text("Wallet", style: TextStyle(fontSize: 22))),
  ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the correct screen based on the index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellerDashboard()), // Link to sellers_dashboard.dart
        );
        break;
      case 1: // Messages
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellersMessages()), // Link to sellers_messages.dart
        );
        break;
      case 2: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellersSettings()), // Link to sellers_settings.dart
        );
        break;
      case 3: // Wallet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellersWallet()), // Link to sellers_wallet.dart
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 This keeps the FAB fixed when keyboard appears

      appBar: AppBar(
        title: Text("Wallet"),
        backgroundColor: Color(0xFF004D40),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Overview Section
              Card(
                elevation: 4,
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Wallet Balance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            isBalanceVisible ? "\$${balance.toStringAsFixed(2)}" : "****",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(isBalanceVisible ? Icons.visibility_off : Icons.visibility),
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

              // Transaction History Section
              SizedBox(height: 20),
              Text("Transaction History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(transaction["description"]),
                      subtitle: Text(transaction["date"]),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("\$${transaction["amount"].toStringAsFixed(2)}"),
                          Text(transaction["status"], style: TextStyle(color: transaction["status"] == "Completed" ? Colors.green : Colors.orange)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Withdraw Funds Section
              SizedBox(height: 20),
              Text("Withdraw Funds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: withdrawController,
                decoration: InputDecoration(
                  labelText: "Amount to Withdraw",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle withdraw functionality
                  if (withdrawController.text.isNotEmpty) {
                    double withdrawAmount = double.parse(withdrawController.text);
                    if (withdrawAmount <= balance) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Withdrawal Requested")));
                      setState(() {
                        balance -= withdrawAmount;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Insufficient funds")));
                    }
                  }
                },
                child: Text("Request Withdrawal"),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF004D40)),
              ),
            ],
          ),
        ),
      ),
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
              SizedBox(width: 40), // Space for the FAB
              _buildNavIcon(Icons.settings, 2),
              _buildNavIcon(Icons.account_balance_wallet, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action (post new item, etc.)
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
