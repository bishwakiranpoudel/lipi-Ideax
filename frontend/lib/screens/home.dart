import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/dashboard.dart';
import 'package:frontend/screens/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    Text("Issues Page"),
    Text("Change Requests Page"),
    ProfileScreen(),
  ];

  final List<String> _names = [
    "Dashboard",
    "Issues",
    "Change Requests",
    "Profile"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show all labels
        selectedItemColor: AppColors.primaryColor, // Customize active tab color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), // Replace with your dashboard icon
            label: 'Dashboard', // Replace with your label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error), // Replace with your issues icon
            label: 'Issues', // Replace with your label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cached), // Replace with your change requests icon
            label: 'Change Requests', // Replace with your label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Replace with your profile icon
            label: 'Profile', // Replace with your label
          ),
        ],
      ),
    );
  }
}
