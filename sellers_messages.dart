import 'package:flutter/material.dart';
import 'sellers_dashboard.dart';
import 'sellers_messages.dart';
import 'sellers_settings.dart';
import 'sellers_wallet.dart';
import 'sellers_post_item.dart';

class SellersMessages extends StatefulWidget {
  @override
  _SellersMessagesState createState() => _SellersMessagesState();
}

class _SellersMessagesState extends State<SellersMessages> {
  int _selectedIndex = 1; // This is the Messages screen

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SellerDashboard()));
        break;
      case 1:
      // Already on messages
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellersSettings()));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellersWallet()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 This keeps the FAB fixed when keyboard appears

      appBar: AppBar(
        title: Text("Messages"),
        backgroundColor: Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _buildMessageTile(
            name: "John Doe",
            message: "Is the phone still available?",
            time: "2:30 PM",
            avatarUrl: null,
          ),
          _buildMessageTile(
            name: "Ama Kwame",
            message: "Can I get a discount?",
            time: "1:10 PM",
            avatarUrl: null,
          ),
          _buildMessageTile(
            name: "Sarpong",
            message: "Please share payment details.",
            time: "Yesterday",
            avatarUrl: null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle post item or start new chat
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add, size: 30),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
    );
  }

  Widget _buildMessageTile({
    required String name,
    required String message,
    required String time,
    String? avatarUrl,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal,
        backgroundImage:
        avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(name[0], style: TextStyle(color: Colors.white))
            : null,
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        // TODO: Navigate to chat screen with this person
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Open chat with $name")),
        // );
      },
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
