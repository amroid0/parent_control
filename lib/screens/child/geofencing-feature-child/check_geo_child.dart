import 'package:flutter/material.dart';

class CheckGeoChild extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;

  const CheckGeoChild({
    super.key,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
  });

  @override
  _ChildAppState createState() => _ChildAppState();
}

class _ChildAppState extends State<CheckGeoChild> {
  String _geofenceStatus = "Outside Geofence";

  bool isWithinGeofence(double currentLat, double currentLng, double startLat,
      double startLng, double endLat, double endLng) {
    return (currentLat >= startLat && currentLat <= endLat) &&
        (currentLng >= startLng && currentLng <= endLng);
  }

  void _checkGeofence() {
    double currentLat = 30.0;
    double currentLng = 31.0;

    bool insideGeofence = isWithinGeofence(
      currentLat,
      currentLng,
      widget.startLatitude,
      widget.startLongitude,
      widget.endLatitude,
      widget.endLongitude,
    );

    setState(() {
      _geofenceStatus = insideGeofence ? "Inside Geofence" : "Outside Geofence";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Child Geofence Status")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Current Status:",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              _geofenceStatus,
              style: const TextStyle(fontSize: 28, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _checkGeofence,
              child: const Text("Check Geofence Status"),
            ),
          ],
        ),
      ),
    );
  }
}
