

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import Firebase Auth

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isBalanceVisible = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser; // To hold the current logged-in user

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Get the current user when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, display a message
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        // backgroundColor: const Color(0xFFD9D9D9),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
          title: const Text("Wallet", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Handle more options
              },
            ),
          ],
        ),
        body: const Center(
          child: Text('Please log in to view your wallet.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: const Color(0xFFD9D9D9), // Background color

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Navbar (Green)**
          Container(
            height: 140,
            color: const Color.fromRGBO(0, 77, 64, 1),
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            child:  SafeArea( // Made const
              child: Stack( // Made const
                alignment: Alignment.center,
                children: [
                  // **App Logo on the Left**
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/app_logo_white.png', width: 70, height: 70), // Made const
                  ),
                  // **Centered "Orders" Text**
                  Text(
                    "Wallet",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  // **More Icon on the Right**
                  Align(
                    alignment: Alignment.centerRight,
                    // child: Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Container(
          //   height: 140,
          //   color: const Color.fromRGBO(0, 77, 64, 1), // Green navbar background
          //   padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          //   child: SafeArea( // Use SafeArea to avoid notch interference
          //     child: Row(
          //       children: [
          //         Image.asset('assets/app_logo_white.png', width: 70, height: 70), // App logo
          //         const Spacer(),
          //         const Text(
          //           "Wallet",
          //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          //         ),
          //         const Spacer(),
          //         // IconButton(
          //         //   icon: const Icon(Icons.more_vert, color: Colors.white),
          //         //   onPressed: () {
          //         //     // Handle more options, e.g., show a dialog or menu
          //         //
          //         //   },
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),

          const SizedBox(height: 20), // Space below navbar

          // **Wallet Account Card (using StreamBuilder for balance)**
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('userWallets').doc(_currentUser!.uid).snapshots(), // Using 'userWallets'
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 150, // Give it a height during loading
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700!, Colors.teal.shade600!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                      ],
                    ),
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  );
                }

                if (snapshot.hasError) {
                  print("Error fetching user balance: ${snapshot.error}");
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade700!, Colors.orange.shade600!], // Error gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }

                // Get balance from snapshot. Assuming 'balance' field in 'userWallets' document
                double currentBalance = (snapshot.data?.data() as Map<String, dynamic>?)?['balance'] ?? 0.0;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700!, Colors.teal.shade600!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Account",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isBalanceVisible ? "GHS ${currentBalance.toStringAsFixed(2)}" : "****",
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isBalanceVisible = !_isBalanceVisible;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // **Wallet Actions**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _walletAction(Icons.arrow_downward, "Deposit", () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deposit functionality TBD")));
                  // TODO: Implement Deposit functionality (e.g., navigate to a deposit screen)
                }),
                _walletAction(Icons.arrow_upward, "Withdraw", () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Withdraw functionality TBD")));
                  // TODO: Implement Withdraw functionality (e.g., navigate to a withdrawal screen)
                }),
                _walletAction(Icons.swap_horiz, "Transfer", () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transfer functionality TBD")));
                  // TODO: Implement Transfer functionality (e.g., navigate to a transfer screen)
                }),
                _walletAction(Icons.person, "Referral", () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Referral functionality TBD")));
                  // TODO: Implement Referral functionality
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // **Recent Transactions - Scrollable (using StreamBuilder)**
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align title to start
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 10.0), // Adjust padding as needed
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('userWallets') // Using 'userWallets'
                          .doc(_currentUser!.uid)
                          .collection('userTransactions') // Using 'userTransactions'
                          .orderBy('timestamp', descending: true) // Order by timestamp
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          print("Error fetching user transactions: ${snapshot.error}");
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No transactions yet.'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 10),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final transactionDoc = snapshot.data!.docs[index];
                            final transactionData = transactionDoc.data() as Map<String, dynamic>;

                            // Extract data fields from Firestore
                            String type = transactionData["type"] ?? "Transaction";
                            double amount = (transactionData["amount"] ?? 0.0).toDouble();
                            String name = transactionData["name"] ?? "N/A";
                            Timestamp? timestamp = transactionData["timestamp"] as Timestamp?;

                            // Determine colors and icons based on amount sign
                            Color transactionColor;
                            IconData transactionIcon;
                            String amountPrefix = '';

                            if (amount >= 0) { // Assuming positive amount is income/deposit
                              transactionColor = Colors.green.shade700!;
                              transactionIcon = Icons.arrow_downward; // Represents money coming in
                              amountPrefix = '+';
                            } else { // Negative amount is withdrawal/sent
                              transactionColor = Colors.red.shade700!;
                              transactionIcon = Icons.arrow_upward; // Represents money going out
                            }

                            // Format timestamp for display
                            String dateString = 'No Date';
                            if (timestamp != null) {
                              DateTime dateTime = timestamp.toDate();
                              dateString = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                            }

                            return Card( // Wrap ListTile in Card for elevation
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8.0), // Add margin between cards
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: transactionColor,
                                  child: Icon(transactionIcon, color: Colors.white),
                                ),
                                title: Text(
                                  "$type - GHS $amountPrefix${amount.abs().toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "$name - $dateString", // Combine name and date
                                  style: const TextStyle(color: Colors.black54),
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
            ),
          ),
        ],
      ),
    );
  }

  // **Wallet Action Buttons**
  // Now accepts an onTap callback
  Widget _walletAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Call the onTap callback when tapped
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.shade700, // Consistent green for actions
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}