import 'dart:convert';
import 'dart:ui';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/child.dart';
import '../child_profile/child_profile_screen.dart';
import 'home_parent_cubit.dart';
import 'location_child_cubit.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

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
        title: const Text('Home'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addChild');
        },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: BlocProvider(
        create: (context) => ParentHomeCubit()..fetchChildren(parentId),
        child: BlocBuilder<ParentHomeCubit, ParentHomeState>(
          builder: (context, state) {
            if (state is ParentHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParentHomeLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Children:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.children.length,
                      itemBuilder: (context, index) {
                        Child child = state.children[index];
                        return ListTile(
                          leading:  CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.child_care,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          title: Text(child.name),
                          subtitle: Text(child.email),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildTokenScreen(
                                    token: child.token, name: child.name),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is ParentHomeError) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}

class LocationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Locations Tab'));
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
        const SizedBox(height: 20),
        const Text(
          'User Name',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            // Navigate to settings
            Navigator.pushNamed(context, '/settings');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            // Logout
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/loginParent');
          },
        ),
      ],
    );
  }
}
