import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:practice_app/animations/slide_transition.dart';
import 'package:practice_app/firebase_options.dart';
import 'package:practice_app/misc/misc_methods.dart';
import 'package:practice_app/providers/file_selection_provider.dart';
import 'package:practice_app/providers/post_delete_provider.dart';
import 'package:practice_app/providers/posts_provider.dart';
import 'package:practice_app/providers/user_provider.dart';
import 'package:practice_app/splash_screen.dart';
import 'package:practice_app/views/mainpage_view.dart';
import 'package:practice_app/views/auth/login.dart';
import 'package:practice_app/views/auth/signup.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  requestPermission();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FileSelectionProvider()),
        ChangeNotifierProvider(create: (_) => PostDeleteProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        StreamProvider<QuerySnapshot?>(
          create:
              (context) =>
                  Provider.of<PostsProvider>(
                    context,
                    listen: false,
                  ).postsStream,
          initialData: null,
          catchError: (_, __) => null,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 30, 90, 194),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 218, 95),
          primary: const Color.fromARGB(255, 255, 218, 95),
        ),
        primaryColor: const Color.fromARGB(255, 227, 195, 91),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            fontSize: 35,
            color: const Color.fromARGB(185, 0, 0, 0),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        final String? args = settings.arguments as String?;
        final bool isExitingSplashScreen = (args == 'Exiting splash screen');
        final Duration transitionDuration =
            isExitingSplashScreen
                ? const Duration(seconds: 3)
                : const Duration(seconds: 2);
        switch (settings.name) {
          case "/signup":
            return SlideTransitionRoute(
              widget: const Signup(),
              beginOffset: Offset(0.0, 1.0),
              transitionduration: const Duration(seconds: 1),
            );
          case "/login":
            return SlideTransitionRoute(
              widget: const Login(),
              beginOffset: Offset(isExitingSplashScreen ? 1.0 : -1.0, 0.0),
              transitionduration: transitionDuration,
            );

          case "/mainpage":
            return SlideTransitionRoute(
              widget: const MainPageView(),
              beginOffset: Offset(1.0, 0.0),
              transitionduration: transitionDuration,
            );
          default:
            return null;
        }
      },
    );
  }
}
