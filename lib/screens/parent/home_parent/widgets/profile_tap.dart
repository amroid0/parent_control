import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
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
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/loginParent');
          },
        ),
      ],
    );
  }
}
