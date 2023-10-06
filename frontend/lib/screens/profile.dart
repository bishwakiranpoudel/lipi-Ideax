import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          //Logout
          await FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Wrapper()),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: AppColors.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: 50.0,
            vertical: 15.0,
          ),
        ),
        child: Text('Logout'),
      ),
    );
  }
}
