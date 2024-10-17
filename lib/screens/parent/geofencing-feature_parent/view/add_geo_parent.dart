import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_control/screens/parent/geofencing-feature_parent/cubit/geo_parent_cubit.dart';

class AddGeoParent extends StatefulWidget {
  const AddGeoParent({Key? key}) : super(key: key);

  @override
  _AddGeoParentState createState() => _AddGeoParentState();
}

class _AddGeoParentState extends State<AddGeoParent> {
  LatLng? _safeZoneLocation;

  // Default location if GPS is not available
  final LatLng _initialLocation =
      const LatLng(30.033333, 31.233334); // Cairo, Egypt

  // Method to set the selected location on the map
  void _onMapTap(LatLng location) {
    setState(() {
      _safeZoneLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Safe Zone"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialLocation,
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {},
              onTap: _onMapTap, // Method to handle map tap
              markers: _safeZoneLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('safe_zone'),
                        position: _safeZoneLocation!,
                      )
                    }
                  : {},
            ),
          ),
          if (_safeZoneLocation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                      "Safe Zone Location: ${_safeZoneLocation!.latitude}, ${_safeZoneLocation!.longitude}"),
                  ElevatedButton(
                    onPressed: () {
                      // Pass the selected location to the GeofenceCubit
                      context.read<GeofenceCubit>().setSafeZone(
                            _safeZoneLocation!.latitude,
                            _safeZoneLocation!.longitude,
                          );
                      Navigator.pop(context, _safeZoneLocation);
                    },
                    child: const Text("Confirm Safe Zone"),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Tap on the map to set the Safe Zone."),
            ),
        ],
      ),
    );
  }
}
