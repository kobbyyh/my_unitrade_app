// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'screens/university_selection.dart';
// import 'screens/home_screen.dart';
// import 'screens/cart_screen.dart';
// import 'screens/wallet_page.dart';
// import 'screens/settings_page.dart';
// import 'screens/chat_page.dart';
// import 'screens/profile_settings.dart';
// import 'screens/privacy_and_security.dart';
// import 'screens/notifications.dart';
// import 'screens/get_help.dart';
// import 'screens/platform_fees.dart';
// import 'screens/signup_seller.dart';
// import 'screens/login_screen.dart';
// import 'screens/login_seller.dart';
// import 'screens/forgot_password.dart';
// import 'screens/sellers_dashboard.dart';
// import 'screens/sellers_post_item.dart';
// import 'screens/sellers_messages.dart';
// import 'screens/sellers_settings.dart';
// import 'screens/sellers_wallet.dart';
// import 'screens/email_verification_screen.dart';
//
// void main() async {
//     WidgetsFlutterBinding.ensureInitialized(); // Required for async Firebase init
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//     );
//     // print('🔥 Firebase initialized successfully!');
//     runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//     @override
//     Widget build(BuildContext context) {
//         return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(
//                 primaryColor: Color(0xFF004D40),
//             ),
//             home: UniversitySelection(),
//         );
//     }
// }



// lib/main.dart



import 'package:UniTrade/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/university_selection.dart';
import 'package:UniTrade/screens/chat_page.dart'; // Import your MessagesScreen
// import 'screens/home_screen.dart';
// import 'screens/cart_screen.dart';
// import 'screens/wallet_page.dart';
// import 'screens/settings_page.dart';
// import 'screens/chat_page.dart';
// import 'screens/profile_settings.dart';
// import 'screens/privacy_and_security.dart';
// import 'screens/notifications.dart';
// import 'screens/get_help.dart';
// import 'screens/platform_fees.dart';
// import 'screens/signup_seller.dart';
// import 'screens/login_screen.dart';
// import 'screens/login_seller.dart';
// import 'screens/forgot_password.dart';
// import 'screens/sellers_dashboard.dart';
// import 'screens/sellers_post_item.dart';
// import 'screens/sellers_messages.dart';
// import 'screens/sellers_settings.dart';
// import 'screens/sellers_wallet.dart';
// import 'screens/email_verification_screen.dart';
import 'package:provider/provider.dart'; // <--- NEW: Import Provider
import 'package:UniTrade/models/cart_model.dart'; // <--- NEW: Import your CartModel

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
        ChangeNotifierProvider( // <--- NEW: Wrap your app with ChangeNotifierProvider
            create: (context) => CartModel(), // <--- NEW: Provide an instance of CartModel
            child: MyApp(), // <--- Your existing MyApp widget
        ),
    );
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: const Color(0xFF004D40), // Added const for consistency
            ),
            // home: SplashScreen(),
            home: UniversitySelection(),
            // You can also define routes here if you wish for named navigation
        );
    }
}






// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// // import 'screens/university_selection.dart'; // We will manage navigation to this from splash screen
// import 'package:UniTrade/screens/splash_screen.dart'; // <--- IMPORTANT: Import your SplashScreen
// import 'package:UniTrade/screens/chat_page.dart';
// import 'package:provider/provider.dart';
// import 'package:UniTrade/models/cart_model.dart';
//
// void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//     );
//     runApp(
//         ChangeNotifierProvider(
//             create: (context) => CartModel(),
//             child: MyApp(),
//         ),
//     );
// }
//
// class MyApp extends StatelessWidget {
//     @override
//     Widget build(BuildContext context) {
//         return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(
//                 primaryColor: const Color(0xFF004D40),
//             ),
//             home: SplashScreen(), // <--- CHANGE THIS LINE TO SplashScreen()
//             // You can also define routes here if you wish for named navigation
//         );
//     }
// }

