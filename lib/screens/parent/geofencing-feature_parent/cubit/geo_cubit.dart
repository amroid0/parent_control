import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'geofencing_state.dart';

class GeofencingCubit extends Cubit<GeofencingState> {
  final LatLng safeZoneCenter;
  final double safeZoneRadius;

  GeofencingCubit({
    required this.safeZoneCenter,
    required this.safeZoneRadius,
  }) : super(GeofencingInitial());

  void startMonitoringLocation(String childId) {
    emit(GeofencingLoading());

    Geolocator.getPositionStream().listen((Position position) {
      final currentLocation = LatLng(position.latitude, position.longitude);
      final distance = _calculateDistance(currentLocation, safeZoneCenter);

      if (distance > safeZoneRadius) {
        _triggerAlert(childId, false);
        _logGeofenceEvent(childId, false);
        emit(GeofencingOutsideZone());
      } else {
        _logGeofenceEvent(childId, true);
        emit(GeofencingInsideZone());
      }
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  void _triggerAlert(String childId, bool insideSafeZone) {
    if (!insideSafeZone) {
      print('الطفل خرج من المنطقة الآمنة');
    }
  }

  void _logGeofenceEvent(String childId, bool entered) {
    FirebaseFirestore.instance.collection('geofenceEvents').add({
      'childId': childId,
      'timestamp': Timestamp.now(),
      'event': entered ? 'entered' : 'left',
    });
  }
}
