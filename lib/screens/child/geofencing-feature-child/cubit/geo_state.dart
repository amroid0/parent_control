// GeofenceChildState

abstract class GeofenceChildState {}

class GeofenceChildInitial extends GeofenceChildState {}

class GeofenceChildLoading extends GeofenceChildState {}

class GeofenceChildLoaded extends GeofenceChildState {
  final double latitude;
  final double longitude;
  GeofenceChildLoaded({required this.latitude, required this.longitude});
}

class GeofenceFailure extends GeofenceChildState {
  final String error;
  GeofenceFailure({required this.error});
}


