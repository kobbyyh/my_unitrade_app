



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import Firebase Auth

import 'sellers_post_item.dart';
import 'sellers_settings.dart';
import 'sellers_messages.dart';
import 'sellers_dashboard.dart';

class SellersWallet extends StatefulWidget {
  @override
  _SellersWalletState createState() => _SellersWalletState();
}

class _SellersWalletState extends State<SellersWallet> {
  bool isBalanceVisible = true; // Toggle visibility of balance

  final TextEditingController withdrawController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentSellerUser; // To hold the current logged-in seller user

  @override
  void initState() {
    super.initState();
    _currentSellerUser = _auth.currentUser; // Get the current user
  }

  int _selectedIndex = 3; // Set to 3 since this is the Wallet screen

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellerDashboard()),
        );
        break;
      case 1: // Messages
        Navigator.pushReplacement( // Changed to pushReplacement to avoid deep stack
          context,
          MaterialPageRoute(builder: (context) => SellersMessages()),
        );
        break;
      case 2: // Settings
        Navigator.pushReplacement( // Changed to pushReplacement
          context,
          MaterialPageRoute(builder: (context) => SellersSettings()),
        );
        break;
      case 3: // Wallet - Already here, no navigation needed
        break;
    }
  }

  // --- Withdraw Functionality with Firestore Update ---
  Future<void> _requestWithdrawal(double currentBalance) async {
    if (withdrawController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount to withdraw.")),
      );
      return;
    }

    double withdrawAmount = double.tryParse(withdrawController.text) ?? 0.0;

    if (withdrawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }

    if (withdrawAmount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient funds.")),
      );
      return;
    }

    if (_currentSellerUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    // Clear the input field immediately
    withdrawController.clear();

    try {
      // Use a transaction to safely update the balance
      await _firestore.runTransaction((transaction) async {
        // --- CHANGED COLLECTION NAME HERE ---
        DocumentReference userWalletDocRef = _firestore.collection('userWallets').doc(_currentSellerUser!.uid);
        DocumentSnapshot userWalletSnapshot = await transaction.get(userWalletDocRef);

        if (!userWalletSnapshot.exists) {
          throw Exception("User wallet document does not exist!");
        }

        double existingBalance = (userWalletSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0.0;
        double newBalance = existingBalance - withdrawAmount;

        // Update the balance in the user's wallet document
        transaction.update(userWalletDocRef, {'balance': newBalance});

        // Add a withdrawal transaction record
        // --- CHANGED COLLECTION NAME HERE ---
        DocumentReference transactionDocRef = userWalletDocRef.collection('userTransactions').doc();
        transaction.set(transactionDocRef, {
          'type': 'Withdrawal',
          'amount': -withdrawAmount, // Store as negative for withdrawals
          'description': 'Withdrawal Request',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Pending', // Or 'Requested', 'Processing'
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Withdrawal requested successfully!")),
      );
    } catch (e) {
      print("Error requesting withdrawal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to request withdrawal: ${e.toString()}")),
      );
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

      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Overview Section (using StreamBuilder)
            StreamBuilder<DocumentSnapshot>(
              // --- CHANGED COLLECTION NAME HERE ---
              stream: _firestore.collection('userWallets').doc(_currentSellerUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    elevation: 4,
                    color: Colors.teal[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print("Error fetching balance: ${snapshot.error}");
                  return Card(
                    elevation: 4,
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                // IMPORTANT: You might need to ensure an initial 'balance' field exists in Firestore
                // for new users/sellers, otherwise this will be 0.0 initially.
                double currentBalance = (snapshot.data?.data() as Map<String, dynamic>?)?['balance'] ?? 0.0;

                return Card(
                  elevation: 4,
                  color: Colors.teal[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Wallet Balance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              isBalanceVisible ? "\$${currentBalance.toStringAsFixed(2)}" : "****",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                );
              },
            ),

            // Transaction History Section (using StreamBuilder)
            const SizedBox(height: 20),
            const Text("Transaction History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
              // --- CHANGED COLLECTION NAME HERE ---
                  .collection('userWallets')
                  .doc(_currentSellerUser!.uid)
              // --- CHANGED SUBCOLLECTION NAME HERE ---
                  .collection('userTransactions')
                  .orderBy('timestamp', descending: true) // Order by most recent transaction
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("Error fetching transactions: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No transactions yet.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Important for nested ListView
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final transactionDoc = snapshot.data!.docs[index];
                    final transactionData = transactionDoc.data() as Map<String, dynamic>;

                    // Format date
                    String transactionDate = '';
                    Timestamp? timestamp = transactionData['timestamp'] as Timestamp?;
                    if (timestamp != null) {
                      DateTime dateTime = timestamp.toDate();
                      transactionDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
                    }

                    // Determine color based on status
                    Color statusColor;
                    switch (transactionData['status']) {
                      case 'Completed':
                        statusColor = Colors.green;
                        break;
                      case 'Pending':
                        statusColor = Colors.orange;
                        break;
                      case 'Failed':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    // Determine if income or expense for amount styling
                    bool isIncome = (transactionData['amount'] ?? 0) >= 0;
                    Color amountColor = isIncome ? Colors.green : Colors.red;
                    String amountPrefix = isIncome ? '+' : '';


                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(transactionData["description"] ?? "No Description"),
                        subtitle: Text(transactionDate),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min, // Ensure it doesn't take too much height
                          children: [
                            Text(
                              "$amountPrefix\$${(transactionData["amount"] ?? 0.0).abs().toStringAsFixed(2)}",
                              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              transactionData["status"] ?? "Unknown",
                              style: TextStyle(color: statusColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Withdraw Funds Section
            const SizedBox(height: 20),
            const Text("Withdraw Funds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // This button now needs the current balance to check against
            StreamBuilder<DocumentSnapshot>(
              // --- CHANGED COLLECTION NAME HERE ---
              stream: _firestore.collection('userWallets').doc(_currentSellerUser!.uid).snapshots(),
              builder: (context, snapshot) {
                double currentBalanceForWithdrawal = (snapshot.data?.data() as Map<String, dynamic>?)?['balance'] ?? 0.0;
                return Column(
                  children: [
                    TextField(
                      controller: withdrawController,
                      decoration: const InputDecoration(
                        labelText: "Amount to Withdraw",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _requestWithdrawal(currentBalanceForWithdrawal),
                      child: const Text("Request Withdrawal", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSellerBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Extracted FloatingActionButton for clarity
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to SellersPostItem or start a new chat if that's the functionality
        Navigator.push(context, MaterialPageRoute(builder: (context) => SellerPostItem()));
      },
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.add, size: 30, color: Colors.white),
      shape: const CircleBorder(),
    );
  }

  // Extracted BottomNavigationBar for clarity
  Widget _buildSellerBottomNavBar() {
    return BottomAppBar(
      color: Colors.blueGrey,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavIcon(Icons.home, 0),
            _buildNavIcon(Icons.message, 1),
            const SizedBox(width: 40), // Spacer for FAB
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