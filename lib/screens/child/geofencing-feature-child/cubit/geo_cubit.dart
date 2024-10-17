// GeofenceChildCubit

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'geo_state.dart';
import 'package:parent_control/screens/parent/geofencing-feature_parent/cubit/geo_parent_cubit.dart';

class GeofenceChildCubit extends Cubit<GeofenceChildState> {
  double? childLatitude;
  double? childLongitude;

  GeofenceChildCubit() : super(GeofenceChildInitial());

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request permissions.');
    }

    // Get current position with high accuracy
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    emit(GeofenceChildLoading());

    try {
      Position position = await _determinePosition();
      childLatitude = position.latitude;
      childLongitude = position.longitude;

      if (childLatitude != null && childLongitude != null) {
        GeofenceCubit().setSafeZone(childLatitude!, childLongitude!);
      }

      emit(GeofenceChildLoaded(
        latitude: childLatitude!,
        longitude: childLongitude!,
      ));
    } catch (e) {
      emit(GeofenceFailure(error: e.toString()));
    }
  }
}
