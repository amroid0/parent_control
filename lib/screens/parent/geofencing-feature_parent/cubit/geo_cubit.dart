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

      // تحديث الحالة بناءً على ما إذا كان الطفل داخل أو خارج المنطقة الآمنة
      if (distance > safeZoneRadius) {
        // خارج المنطقة الآمنة
        _triggerAlert(childId, false);
        _logGeofenceEvent(childId, false);
        emit(GeofencingOutsideZone());
      } else {
        // داخل المنطقة الآمنة
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
      // تنفيذ التنبيه هنا
      print('الطفل خرج من المنطقة الآمنة');
    }
  }

/*************  ✨ Codeium Command 🌟  *************/
  /// سجل حدث دخول / خروج الطفل من المنطقة الآمنة
  ///
  /// [childId] هو معرف الطفل
  /// [entered] هو true إذا دخل الطفل المنطقة الآمنة، false إذا خرج
  void _logGeofenceEvent(String childId, bool entered) {
    FirebaseFirestore.instance.collection('geofenceEvents').add({
      'childId': childId,
      'timestamp': Timestamp.now(),
      'event': entered ? 'entered' : 'left',
    });
  }
/******  05205289-ac49-4647-a18e-d66d5de13b6b  *******/
}
