import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/addprofile.dart';
import 'package:frontend/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // _navigatetohome();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.asset('assets/logo.png'),
    );
  }

  startTimer() async {
    await Future.delayed(Duration(milliseconds: 1000));
    navigateUser();
  }

  void navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    late StreamSubscription<User?> user;
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Not Logged In Navigate to signin Screen
        Navigator.pushNamed(context, '/login');
      } else {
        // Logged In check if user has a profile
        _profcheck(context);
      }
    });
  }
}

_profcheck(context) async {
  final User? user = FirebaseAuth.instance.currentUser;
  final String uid = user!.uid.toString();
  print(user);
  QuerySnapshot<Map<String, dynamic>> a = await FirebaseFirestore.instance
      .collection('profiles')
      .where("uid", isEqualTo: uid)
      .get();
  if (a.docs.isNotEmpty) {
    // If use has profile navigate to HomeScreen
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false);
  } else {
    // If user doesn't have profile navigate to AddProfile Screen
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AddProfileScreen()),
        (route) => false);
  }
}
