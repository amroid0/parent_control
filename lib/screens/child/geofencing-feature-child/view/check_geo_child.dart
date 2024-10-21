import 'package:flutter/material.dart';

class CheckGeoChild extends StatelessWidget {
  const CheckGeoChild({super.key});
  static const String routeName = '/checkGeoChild';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Child Home")),
        body: const Text(
          'Check GeoFencing',
        ));
  }
}
