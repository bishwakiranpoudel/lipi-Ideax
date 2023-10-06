import 'package:flutter/widgets.dart';
import 'package:frontend/screens/addprofile.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/signup.dart';
import 'package:frontend/screens/wrapper.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => Wrapper(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/home': (context) => HomeScreen(),
  '/addprofile': (context) => AddProfileScreen(),
};
