import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationCubit extends Cubit<Position?> {
  LocationCubit(this.childId) : super(null);
  String childId;

  Future<void> startListening() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getPositionStream().listen((Position position) {
      emit(position);
      pushLocationToFirestore(position);
    });
  }

  Future<void> pushLocationToFirestore(Position position) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('children')
        .doc(childId)
        .collection('locations')
        .add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> startForegroundService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_service',
        channelName: 'Location Tracking Service',
        channelDescription:
            'This service is used for tracking the user\'s location.',
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.once(),
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );

    FlutterForegroundTask.startService(
      notificationTitle: 'Location Tracking',
      notificationText: 'Tracking your location...',
      callback: startCallback,
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  LocationCubit? _locationCubit;

  @override
  Future<void> onStart(
    DateTime timestamp,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? childId = prefs.getString('childId');
    _locationCubit = LocationCubit(childId!);
    _locationCubit!.startListening();
  }

  @override
  void onEvent(
    DateTime timestamp,
  ) {
    // Handle events if needed
  }

  @override
  void onDestroy(
    DateTime timestamp,
  ) {
    _locationCubit?.close();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}
}
