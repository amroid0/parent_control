import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import '../location_child_cubit.dart';

import '../../geofencing-feature_parent/view/add_geo_parent.dart';
import '../../widgets/loading.dart';

class LocationsTab extends StatefulWidget {
  const LocationsTab({super.key});

  @override
  _LocationsTabState createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Uint8List? _markerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    final icon = await getBytesFromAsset('assets/child.png', 120);
    setState(() {
      _markerIcon = icon;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (context) => ChildLocationsCubit(parentId)..listenToLocations(),
      child: BlocBuilder<ChildLocationsCubit, ChildLocationsState>(
        builder: (context, state) {
          if (state is ChildLocationsLoading) {
            return const Center(child:  LoadingWidget());
          } else if (state is ChildLocationsLoaded) {
            return Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
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
                              icon: _markerIcon == null
                                  ? BitmapDescriptor.defaultMarker
                                  : BitmapDescriptor.fromBytes(_markerIcon!),
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
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text(
                                    childName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SafeZoneScreen(
                                            childId: childId,
                                            initialLocation: _selectedLocation!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Set Safe Zone'),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
