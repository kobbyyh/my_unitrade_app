
import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isBalanceVisible = true;
  double balance = 500.00; // Example balance

  // Transaction List
  final List<Map<String, dynamic>> transactions = [
    {"type": "Deposit", "amount": 500.00, "name": "MTN MoMo", "color": Colors.green, "icon": Icons.arrow_downward},
    {"type": "Withdrawal", "amount": 200.00, "name": "Bank Account", "color": Colors.red, "icon": Icons.arrow_upward},
    {"type": "Money Sent", "amount": 150.00, "name": "John Doe", "color": Colors.orange, "icon": Icons.send},
    {"type": "Transfer", "amount": 100.00, "name": "Kwesi Mensah", "color": Colors.blue, "icon": Icons.swap_horiz},
    {"type": "Received", "amount": 250.00, "name": "Akosua Boadu", "color": Colors.purple, "icon": Icons.call_received},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xD9D9D9), // Background color

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Navbar (Green)**
          Container(
            color: Color.fromRGBO(0, 77, 64, 1), // Green navbar background
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            child: Row(
              children: [
                Image.asset('assets/app_logo_white.png', width: 70, height: 70), // App logo
                Spacer(),
                Text(
                  "Wallet",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Spacer(),
                Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),

          SizedBox(height: 20), // Space below navbar

          // **Wallet Account Card**
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isBalanceVisible ? "GHS ${balance.toStringAsFixed(2)}" : "****",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
            ),
          ),

          SizedBox(height: 20),

          // **Wallet Actions**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _walletAction(Icons.arrow_downward, "Deposit"),
                _walletAction(Icons.arrow_upward, "Withdraw"),
                _walletAction(Icons.swap_horiz, "Transfer"),
                _walletAction(Icons.person, "Referral"),
              ],
            ),
          ),

          SizedBox(height: 20),

          // **Recent Transactions - Scrollable**
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(12),
                //   boxShadow: [
                //     BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
                //   ],
                // ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Recent Transactions",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 10),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction["color"],
                              child: Icon(transaction["icon"], color: Colors.white),
                            ),
                            title: Text(
                              "${transaction["type"]} - GHS ${transaction["amount"].toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              transaction["type"] == "Received"
                                  ? "From: ${transaction["name"]}"
                                  : "To: ${transaction["name"]}",
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // **Wallet Action Buttons**
  Widget _walletAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade700,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
