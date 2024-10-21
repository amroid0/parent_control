import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildLocationsMap extends StatelessWidget {
  final Completer<GoogleMapController> mapController;
  final Map<String, GeoPoint> locations;
  final String? selectedChildId;
  const ChildLocationsMap({
    super.key,
    required this.mapController,
    required this.locations,
    this.selectedChildId,
  });

  Future<void> _moveCamera(GeoPoint location) async {
    final controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        17.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController.complete(controller);

        if (locations.isNotEmpty) {
          final firstLocation = locations.values.first;
          _moveCamera(firstLocation);
        }
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(0, 0),
        zoom: 15,
      ),
      markers: locations.entries.map((entry) {
        return Marker(
          markerId: MarkerId(entry.key),
          position: LatLng(entry.value.latitude, entry.value.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: entry.key),
          onTap: () {
            _moveCamera(entry.value);
          },
        );
      }).toSet(),
    );
  }
}
