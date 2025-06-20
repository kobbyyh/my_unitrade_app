import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF004D40), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/app_logo.png', width: 150, height: 150),
            SizedBox(height: 20),
            Text(
              'UniTrade',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}






// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Ensure this path is correct
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _gradientOpacityAnimation;
//   late Animation<double> _contentOpacityAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize AnimationController
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3), // Total duration for both animations
//     );
//
//     // Animation for the gradient background opacity (e.g., fades in during the first 1 second)
//     _gradientOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeIn), // Fade in gradient during first half
//       ),
//     );
//
//     // Animation for the logo and text opacity (e.g., fades in during the latter half)
//     _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeIn), // Fade in content during second half
//       ),
//     );
//
//     // Start the animation
//     _controller.forward();
//
//     // Navigate to HomeScreen after animation completes + a short delay
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         Timer(const Duration(milliseconds: 500), () { // Short delay after animation
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()),
//           );
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Opacity(
//             opacity: _gradientOpacityAnimation.value, // Control overall gradient opacity
//             child: Container(
//               // The gradient background
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF004D40), Color(0xFF00796B)], // Your desired gradient colors
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Center(
//                 child: Opacity(
//                   opacity: _contentOpacityAnimation.value, // Control content opacity
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Using the logo from your examples (assuming 'assets/app_logo.png' is correct)
//                       // If your logo is actually a cart icon in SVG or different, you might need SvgPicture.asset
//                       Image.asset('assets/app_logo_text1.png', width: 150, height: 150),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'UniTrade', // Changed from 'UniTrades' to 'UniTrade' as per your provided image
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }