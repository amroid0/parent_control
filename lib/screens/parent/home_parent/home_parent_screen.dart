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
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
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
                          leading: Image.asset("assets/child.png",width: 50,height: 50),
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
              return Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}

class LocationsTab extends StatefulWidget {
  @override
  _LocationsTabState createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
   Uint8List? _markerIcon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMarkerIcon();
  }
  Future<void> _loadMarkerIcon() async {
   final  icon=  await getBytesFromAsset('assets/child.png',120);
    setState(() {
      _markerIcon = icon;
    });
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec =
    await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (context) => ChildLocationsCubit(parentId)..listenToLocations(),
      child: BlocBuilder<ChildLocationsCubit, ChildLocationsState>(
        builder: (context, state) {
          if (state is ChildLocationsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ChildLocationsLoaded) {
            return Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 20,
                    ),
                    onMapCreated: (controller) {
                      setState(() {
                        _mapController = controller;
                      });
                    },
                    markers: state.locations.entries
                        .map((entry) => Marker(
                      icon: _markerIcon== null ?BitmapDescriptor.defaultMarker: BitmapDescriptor.fromBytes(_markerIcon!),
                              markerId: MarkerId(entry.key),
                              position: LatLng(
                                entry.value.latitude,
                                entry.value.longitude,
                              ),
                              infoWindow: InfoWindow(
                                title: state.childNames[entry.key],
                              ),
                            ))
                        .toSet(),
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.transparent,
                  child: ListView.builder(

                    scrollDirection: Axis.horizontal,
                    itemCount: state.locations.length,
                    itemBuilder: (context, index) {
                      final childId = state.locations.keys.elementAt(index);
                      final location = state.locations[childId]!;
                      final childName = state.childNames[childId]!;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocation = LatLng(
                                location.latitude,
                                location.longitude,
                              );
                            });
                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: _selectedLocation!,
                                  zoom: 20,
                                ),
                              ),
                            );
                          },
                          child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                  width: 150,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/child.png",
                                        width: 40,
                                        height: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        childName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    ],
                                  ))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ChildLocationsError) {
            return Center(child: Text(state.error));
          } else {
            return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
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
