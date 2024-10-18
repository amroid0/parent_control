import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'alert_view.dart';
import 'geo_screen.dart';

class SafeZoneScreen extends StatefulWidget {
  final String childId;
  final LatLng initialLocation;

  const SafeZoneScreen({
    Key? key,
    required this.childId,
    required this.initialLocation,
  }) : super(key: key);

  @override
  _SafeZoneScreenState createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  double _safeZoneRadius = 100; // القطر المبدئي لمنطقة الأمان

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد منطقة الأمان'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('child_location'),
                position: _selectedLocation!,
                infoWindow: const InfoWindow(title: 'موقع الطفل'),
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId('safe_zone'),
                center: _selectedLocation!,
                radius: _safeZoneRadius, // استخدام القطر المتغير
                strokeColor: Colors.blue.withOpacity(0.5),
                fillColor: Colors.blue.withOpacity(0.3),
                strokeWidth: 1,
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Slider(
                  value: _safeZoneRadius,
                  min: 50,
                  max: 500, // تحديد مدى القطر المسموح به
                  divisions: 10, // تقسيم القيم
                  label: '${_safeZoneRadius.toStringAsFixed(0)} متر',
                  onChanged: (value) {
                    setState(() {
                      _safeZoneRadius = value; // تحديث القطر في الوقت الفعلي
                    });
                  },
                ),
                Text(
                  'نصف قطر منطقة الأمان: ${_safeZoneRadius.toStringAsFixed(0)} متر',
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedLocation != null) {
                          _saveSafeZone();
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('يرجى تحديد منطقة الأمان أولاً')),
                          );
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlertSettingsScreen(),
                          ),
                        );
                      },
                      child: const Text('إعدادات التنبيهات'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeofencingScreen(
                              safeZoneCenter: _selectedLocation!,
                              safeZoneRadius: _safeZoneRadius,
                            ),
                          ),
                        );
                      },
                      child: const Text('مراقبة الطفل'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveSafeZone() {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;
    final double latitude = _selectedLocation!.latitude;
    final double longitude = _selectedLocation!.longitude;

    print(
        'Safe Zone saved for child: $latitude, $longitude with radius $_safeZoneRadius meters');
  }
}
