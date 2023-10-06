import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/addprofile.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 350,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: MyClipper(),
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      left: MediaQuery.of(context).size.width / 2 - 75,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.contain,
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email field
                    Container(
                      width: 300.0,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          labelStyle:
                              TextStyle(color: AppColors.textaccentColor),
                        ),
                        cursorColor: AppColors.textColor,
                      ),
                    ),

                    SizedBox(height: 20.0),

                    // Password field
                    Container(
                      width: 300.0,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          labelStyle:
                              TextStyle(color: AppColors.textaccentColor),
                        ),
                        cursorColor: AppColors.textColor,
                      ),
                    ),

                    SizedBox(height: 30.0),

                    // Login and register buttons
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        onPressed: () async {
                          print('this');
                          try {
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _emailController.text.toString(),
                                    password:
                                        _passwordController.text.toString());
                            print(credential);
                            _profcheck(context);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              print('No user found for that email.');
                            } else if (e.code == 'wrong-password') {
                              print('Wrong password provided for that user.');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50.0,
                            vertical: 15.0,
                          ),
                        ),
                        child: Text('Login'),
                      ),
                      SizedBox(width: 20.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          primary: AppColors
                              .primaryColor, // Set the text color to blue
                        ),
                        child: Text('Register'),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

_profcheck(context) async {
  final User? user = FirebaseAuth.instance.currentUser;
  final String uid = user!.uid.toString();
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
