import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'safe_zone_state.dart';

class SafeZoneCubit extends Cubit<SafeZoneState> {
  SafeZoneCubit() : super(SafeZoneInitial());

  void updateLocation(LatLng location) {
    emit(SafeZoneLocationUpdated(location));
  }

  void updateRadius(double radius) {
    emit(SafeZoneRadiusUpdated(radius));
  }


  void saveSafeZone(String parentId, LatLng location, double radius) {
    // Logic to save the safe zone
    emit(SafeZoneSaved(location, radius));
  }
}
