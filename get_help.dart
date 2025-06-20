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
              subtitle: Text('Send us a mail of your username and school email.'
                  'You will receive a link from us (UniTrade) to reset your password. if we confirm you are an authenticated user.'),
            ),
            ListTile(
              title: Text('How to contact support?'),
              subtitle: Text('Send us a mail of your query and we will attend to you.'),
            ),
            // Add more FAQs as needed
          ],
        ),
        ExpansionTile(
          title: Text('Contact Support'),
          children: [
            ListTile(
              title: Text('Email Support'),
              subtitle: Text('help.unitrade.app@gmail.com'),
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
              subtitle: Text('We are committed to protecting your privacy and ensuring the security of your personal data. By using the UniTrade App, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree with the terms outlined in this policy, please do not use the UniTrade App.'
              'This policy applies to all users of the UniTrade App, including buyers and sellers, and covers data collected through your interactions with the App, its services, and any related communications. Our goal is to provide a safe and reliable platform for university students to buy and sell items within their university community.'),
              onTap: () {
                // Navigate to Privacy Policy details or show dialog

              },
            ),
            ListTile(
              title: Text('Terms of Service'),
              subtitle: Text('Welcome to UniTrade! These Terms of Service ("Terms") govern your access to and use of the UniTrade mobile application (the "App" or "Service"). UniTrade is designed to connect university students for the buying and selling of goods and services within their university community.'
              'By downloading, installing, accessing, or using the UniTrade App, you acknowledge that you have read, understood, and agree to be bound by these Terms, as well as our Privacy Policy. If you do not agree with any part of these Terms, you may not access or use the Service.'

                'These Terms constitute a legally binding agreement between you and UniTrade. We reserve the right to modify these Terms at any time. Your continued use of the App following any such modifications signifies your acceptance of the updated Terms. We encourage you to review these Terms regularly.'),
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



