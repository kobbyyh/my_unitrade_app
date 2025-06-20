

import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool messagesEnabled = true;
  bool orderUpdatesEnabled = true;
  bool promotionsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 77, 64, 1),
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildNotificationToggle(
              "Messages",
              "Turn on notifications for messages",
              messagesEnabled,
                  (value) {
                setState(() {
                  messagesEnabled = value;
                });
              },
            ),
            _buildNotificationToggle(
              "Order Updates",
              "Turn on notifications for order updates",
              orderUpdatesEnabled,
                  (value) {
                setState(() {
                  orderUpdatesEnabled = value;
                });
              },
            ),
            _buildNotificationToggle(
              "Promotions",
              "Turn on notifications for promotions",
              promotionsEnabled,
                  (value) {
                setState(() {
                  promotionsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
      String title, String description, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Divider(),
        ],
      ),
    );
  }
}
