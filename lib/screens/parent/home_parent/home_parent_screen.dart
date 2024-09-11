import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/child.dart';
import '../child_profile/child_profile_screen.dart';
import 'home_parent_cubit.dart';

class ParentHomeScreen extends StatefulWidget {
  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomeTab(),
    LocationsTab(),
    ProfileTab(),
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
        title: Text('Home'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
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
  @override
  Widget build(BuildContext context) {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addChild');
        },
        child: Icon(Icons.add),
      ),
      body: BlocProvider(
        create: (context) => ParentHomeCubit()..fetchChildren(parentId),
        child: BlocBuilder<ParentHomeCubit, ParentHomeState>(
          builder: (context, state) {
            if (state is ParentHomeLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ParentHomeLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Childern:',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.children.length,
                      itemBuilder: (context, index) {
                        Child child = state.children[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          title: Text(child.name),
                          subtitle: Text(child.email),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildTokenScreen(token: child.token, name: child.name),
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
              return Center(child: Text('Something went wrong'));
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
        SizedBox(height: 20),
        Text(
          'User Name',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Navigate to settings
            Navigator.pushNamed(context, '/settings');
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
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