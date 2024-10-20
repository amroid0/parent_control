import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SafeZoneMap extends StatelessWidget {
  final LatLng initialLocation;
  final LatLng selectedLocation;

  const SafeZoneMap({
    Key? key,
    required this.initialLocation,
    required this.selectedLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialLocation,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('child_location'),
          position: selectedLocation,
          infoWindow: const InfoWindow(title: 'Child Location'),
        ),
      },
      circles: {
        Circle(
          circleId: const CircleId('safe_zone'),
          center: selectedLocation,
          radius: 100,
          strokeColor: Colors.blue.withOpacity(0.5),
          fillColor: Colors.blue.withOpacity(0.3),
          strokeWidth: 1,
        ),
      },
    );
  }
}
