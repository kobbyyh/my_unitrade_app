import 'package:flutter/material.dart';
import 'home_page.dart';
import 'orders_page.dart';
import 'chat_page.dart';
import 'settings_page.dart';
import 'wallet_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('UniTrade'),
          backgroundColor: Color(0xFF004D40),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Orders'),
              Tab(icon: Icon(Icons.chat), text: 'Chat'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Wallet'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),
            OrdersPage(),
            ChatPage(),
            SettingsPage(),
            WalletPage(),
          ],
        ),
      ),
    );
  }
}
