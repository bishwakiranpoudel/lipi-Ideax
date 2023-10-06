import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/routes.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<User?> user;
  bool go = true;

  void initState() {
    super.initState();
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        print('User is currently signed out!');
        go = false;
      } else {
        print('User is signed in!');
        go = true;
      }
    });
  }

  @override
  void dispose() {
    user.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lipi',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: AppColors.primaryColor, // Set the app bar background color
        ),
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor, // Set the primary color
        ),
        textTheme: TextTheme(
          bodyText1: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: AppColors.textColor,
            ),
          ),
          bodyText2: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: AppColors.textColor,
            ),
          ),
        ),
      ),
      routes: routes,
    );
  }
}
