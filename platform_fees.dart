import 'package:flutter/material.dart';

class PlatformFeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Platform Fees')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Platform Fees',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: 16),
            Text(
              'Our platform charges a 20% service fee on all transactions. This means that for every sale made, 80% of the earnings go directly to you, and 20% is retained by the platform.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'The service fee supports the continuous development of our platform, ensuring a seamless experience for both sellers and buyers. It also funds our customer support and marketing initiatives to expand our user base.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Our 20% service fee is in line with industry standards. For example, Uber charges partners a 20% fee on all fares, which covers the use of Uber software, collection and transfer of fares, credit card commission, and distribution of invoices to clients.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Payments are processed weekly, with earnings deposited directly into your registered bank account every Monday. Please ensure your banking details are up to date to avoid any delays.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'If you have any questions regarding our fee structure, please contact our support team at support@example.com.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
