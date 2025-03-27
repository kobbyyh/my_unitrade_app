// import 'package:Uni_Trade/screens/get_help.dart';
// import 'package:flutter/material.dart';
// import 'profile_settings.dart'; // Import Profile Settings screen
// import 'privacy_and_security.dart'; // Import Privacy & Security screen
// import 'notifications.dart';
// import 'get_help.dart';
//
// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xD9D9D9),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: 70),
//           Center(
//             child: Image.asset(
//               'assets/app_logo_white.png',
//               width: 100,
//               height: 100,
//             ),
//           ),
//           SizedBox(height: 40),
//
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               children: [
//                 settingsItem(
//                   context,
//                   Icons.person,
//                   "Profile settings",
//                   Colors.blue,
//                   ProfileSettingsScreen(),
//                 ),
//                 settingsItem(
//                   context,
//                   Icons.lock,
//                   "Privacy and Security",
//                   Colors.red,
//                   PrivacyAndSecurityScreen(), // ✅ Now linked properly
//                 ),
//
//                 settingsItem(context,
//                     Icons.notifications,
//                     "Notifications",
//                     Colors.yellow,
//                     NotificationsScreen(),
//                 ),
//
//                 settingsItem(context,
//                     Icons.help,
//                     "Get Help",
//                     Colors.green,
//                     GetHelpSection(),
//                 ),
//
//                 settingsItem(context,
//                     Icons.attach_money,
//                     "Platform Fees & Commission",
//                     Colors.purple,
//                     null
//                 ),
//
//                 settingsItem(context,
//                     Icons.store,
//                     "Login As A Seller",
//                     Colors.brown,
//                     null
//                 ),
//
//                 settingsItem(context, Icons.exit_to_app, "Logout", Colors.orange, null),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🔹 Reusable Widget for Settings Items
//   Widget settingsItem(BuildContext context, IconData icon, String title, Color iconColor, Widget? page)
//   {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: ListTile(
//         leading: Icon(icon, color: iconColor),
//         title: Text(
//           title,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         onTap: page != null
//             ? () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => page),
//           );
//         }
//             : null, // If no page assigned, do nothing
//       ),
//     );
//   }
//
//
//
// }



import 'package:flutter/material.dart';
import 'profile_settings.dart';
import 'privacy_and_security.dart';
import 'notifications.dart';
import 'get_help.dart'; // Import GetHelpSection
import 'platform_fees.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xD9D9D9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 70),
          Center(
            child: Image.asset(
              'assets/app_logo_white.png',
              width: 100,
              height: 100,
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                settingsItem(
                  context,
                  Icons.person,
                  "Profile settings",
                  Colors.blue,
                  ProfileSettingsScreen(),
                ),
                settingsItem(
                  context,
                  Icons.lock,
                  "Privacy and Security",
                  Colors.red,
                  PrivacyAndSecurityScreen(),
                ),
                settingsItem(
                  context,
                  Icons.notifications,
                  "Notifications",
                  Colors.yellow,
                  NotificationsScreen(),
                ),


                settingsItem(
                  context,
                  Icons.attach_money,
                  "Platform Fees & Commission",
                  Colors.purple,
                  PlatformFeesScreen(),
                ),
                settingsItem(
                  context,
                  Icons.store,
                  "Login As A Seller",
                  Colors.brown,
                  null,
                ),
                settingsItem(
                  context,
                  Icons.exit_to_app,
                  "Logout",
                  Colors.orange,
                  null,
                ),

                // Embed GetHelpSection directly
                GetHelpSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget for Settings Items
  Widget settingsItem(BuildContext context, IconData icon, String title, Color iconColor, Widget? page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: page != null
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
            : null, // If no page assigned, do nothing
      ),
    );
  }
}
