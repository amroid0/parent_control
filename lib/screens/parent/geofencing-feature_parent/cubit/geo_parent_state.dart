
// States
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class GeofenceState {}

class GeofenceInitial extends GeofenceState {}

class GeofenceSafeZoneSet extends GeofenceState {
  final LatLng safeZone;
  GeofenceSafeZoneSet(this.safeZone);
}
