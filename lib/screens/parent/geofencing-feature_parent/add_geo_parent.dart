import 'package:flutter/material.dart';

import '../../child/geofencing-feature-child/check_geo_child.dart';

class ParentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ParentHomeScreen(),
    );
  }
}

class ParentHomeScreen extends StatefulWidget {
  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _startLatitude;
  String? _startLongitude;
  String? _endLatitude;
  String? _endLongitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Geofence Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Start Latitude"),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _startLatitude = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Start Latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Start Longitude"),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _startLongitude = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Start Longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "End Latitude"),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _endLatitude = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter End Latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "End Longitude"),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _endLongitude = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter End Longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckGeoChild(
                          startLatitude: double.parse(_startLatitude!),
                          startLongitude: double.parse(_startLongitude!),
                          endLatitude: double.parse(_endLatitude!),
                          endLongitude: double.parse(_endLongitude!),
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Set Geofence"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
