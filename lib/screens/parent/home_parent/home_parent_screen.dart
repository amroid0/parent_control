import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'widgets/home_tab.dart';
import 'widgets/location_tap.dart';
import 'widgets/profile_tap.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});
  static const String routeName = '/parentHome';
  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const HomeTab(),
    const LocationsTab(),
    const ProfileTab(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Home'),
        automaticallyImplyLeading: false,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.location_on),
            title: const Text("Locations"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
