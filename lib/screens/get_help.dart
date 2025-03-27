import 'package:flutter/material.dart';

class GetHelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: Text('FAQs'),
          children: [
            ListTile(
              title: Text('How to reset my password?'),
              subtitle: Text('Go to settings and select "Change Password".'),
            ),
            ListTile(
              title: Text('How to contact support?'),
              subtitle: Text('Use the "Contact Support" section below.'),
            ),
            // Add more FAQs as needed
          ],
        ),
        ExpansionTile(
          title: Text('Contact Support'),
          children: [
            ListTile(
              title: Text('Email Support'),
              subtitle: Text('support@example.com'),
              onTap: () {
                // Implement email launch functionality
              },
            ),
            ListTile(
              title: Text('Call Support'),
              subtitle: Text('+233-542-367-268'),
              onTap: () {
                // Implement call functionality
              },
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Terms & Policies'),
          children: [
            ListTile(
              title: Text('Privacy Policy'),
              subtitle: Text('UniTrade Privacy Policy is ...'),
              onTap: () {
                // Navigate to Privacy Policy details or show dialog

              },
            ),
            ListTile(
              title: Text('Terms of Service'),
              subtitle: Text('UniTrade Terms of Service is ...'),
              onTap: () {
                // Navigate to Terms of Service details or show dialog
              },
            ),
          ],
        ),
      ],
    );
  }
}
