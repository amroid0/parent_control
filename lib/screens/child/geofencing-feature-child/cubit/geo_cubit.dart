import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:parent_control/screens/child/geofencing-feature-child/cubit/geo_state.dart';

class LocationCubit extends Cubit<LocationState> {
  Timer? _timer;
  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  LocationCubit() : super(LocationInitial());

  // التحقق من أذونات الموقع
  Future<void> checkLocationPermission() async {
    final permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final permissionRequested = await _geolocator.requestPermission();
      if (permissionRequested == LocationPermission.denied) {
        emit(LocationPermissionDenied());
        return;
      }
    }
    emit(LocationPermissionGranted());
  }

  // تحديث الموقع كل 30 ثانية
  void startUpdatingLocation() {
    _timer?.cancel(); // لو فيه تايمر قديم نلغيه
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      final position = await _geolocator.getCurrentPosition();
      emit(LocationUpdated(position));
    });
  }

  // التحقق من الـ Safe Zone
  void checkIfInSafeZone(Position position, Position safeZonePosition, double radius) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      safeZonePosition.latitude,
      safeZonePosition.longitude,
    );
    
    if (distance <= radius) {
      emit(InsideSafeZone());
    } else {
      emit(OutsideSafeZone());
    }
  }

  // وقف التحديث
  void stopUpdatingLocation() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    stopUpdatingLocation();
    return super.close();
  }
}
