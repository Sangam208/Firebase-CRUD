import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/create_post.dart';
import 'package:my_app/firebase_options.dart';
import 'package:my_app/home.dart';
import 'package:my_app/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(139, 186, 236, 0.698),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(226, 251, 116, 0.694),
        ),
        primaryColor: Color.fromRGBO(193, 211, 113, 0.686),
        textTheme: TextTheme(
          titleMedium: TextStyle(
            fontFamily: 'Lato',
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            fontFamily: 'Lato',
            color: Colors.black87,
          ),
        ),
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            if (snapshot.data != null) {
              return const Home();
            }
            return const Login();
          }),
      routes: {
        "/upload": (context) => CreatePost(),
      },
    );
  }
}
