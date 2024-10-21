import 'package:geolocator/geolocator.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationPermissionGranted extends LocationState {}

class LocationPermissionDenied extends LocationState {}

class LocationUpdated extends LocationState {
  final Position position;
  LocationUpdated(this.position);
}

class InsideSafeZone extends LocationState {}

class OutsideSafeZone extends LocationState {}
