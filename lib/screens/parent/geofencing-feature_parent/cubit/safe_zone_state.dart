part of 'safe_zone_cubit.dart';

abstract class SafeZoneState extends Equatable {
  const SafeZoneState();

  @override
  List<Object> get props => [];
}

class SafeZoneInitial extends SafeZoneState {}

class SafeZoneLocationUpdated extends SafeZoneState {
  final LatLng location;

  const SafeZoneLocationUpdated(this.location);

  @override
  List<Object> get props => [location];
}

class SafeZoneRadiusUpdated extends SafeZoneState {
  final double radius;

  const SafeZoneRadiusUpdated(this.radius);

  @override
  List<Object> get props => [radius];
}

class SafeZoneSaved extends SafeZoneState {
  final LatLng location;
  final double radius;

  const SafeZoneSaved(this.location, this.radius);

  @override
  List<Object> get props => [location, radius];
}
