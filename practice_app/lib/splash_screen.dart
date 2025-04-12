import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Your App Logo in the center
          Center(child: Image.asset('assets/images/app_logo.png')),

          // Lottie Animation at the bottom
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/animations/loading_hand.json',
              height: 280,
            ),
          ),

          // StreamBuilder to handle auth state and navigation
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // If auth state is loading, show loading indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              Future.delayed(Duration(seconds: 10), () {
                // If user is logged in, navigate to the main page
                if (snapshot.data != null) {
                  Navigator.pushReplacementNamed(context, '/mainpage');
                } else {
                  // If user is not logged in, navigate to the login page
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                    arguments: 'Exiting splash screen',
                  );
                }
              });

              return SizedBox.shrink(); // Return an empty widget since we're already handling navigation
            },
          ),
        ],
      ),
    );
  }
}
