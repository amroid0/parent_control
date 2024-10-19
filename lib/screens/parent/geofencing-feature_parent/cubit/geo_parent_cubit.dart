import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'geo_parent_state.dart';

class GeofenceCubit extends Cubit<GeofenceState> {
  LatLng? _safeZone;

  GeofenceCubit() : super(GeofenceInitial());

  void setSafeZone(double latitude, double longitude) {
    _safeZone = LatLng(latitude, longitude);
    emit(GeofenceSafeZoneSet(_safeZone!));
    // Optionally, save this to a backend or persistent storage
  }

  LatLng? get safeZone => _safeZone;
}
