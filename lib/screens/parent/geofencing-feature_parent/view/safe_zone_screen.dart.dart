import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cubit/safe_zone_cubit.dart';
import 'widget/safe_zone_controls.dart';
import 'widget/safe_zone_map.dart';

class SafeZoneScreen extends StatelessWidget {
  final String childId;
  final LatLng initialLocation;

  const SafeZoneScreen({
    super.key,
    required this.childId,
    required this.initialLocation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SafeZoneCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Safe Zone'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<SafeZoneCubit, SafeZoneState>(
                builder: (context, state) {
                  LatLng selectedLocation = initialLocation;
                  if (state is SafeZoneLocationUpdated) {
                    selectedLocation = state.location;
                  }

                  return SafeZoneMap(
                    initialLocation: initialLocation,
                    selectedLocation: selectedLocation,
                  );
                },
              ),
            ),
            BlocBuilder<SafeZoneCubit, SafeZoneState>(
              builder: (context, state) {
                double radius = 100;
                if (state is SafeZoneRadiusUpdated) {
                  radius = state.radius;
                }

                return SafeZoneControls(
                  safeZoneRadius: radius,
                  onRadiusChanged: (value) {
                    context.read<SafeZoneCubit>().updateRadius(value);
                  },
                  onSave: () {
                    final cubit = context.read<SafeZoneCubit>();
                    cubit.saveSafeZone(childId, initialLocation, radius);
                  },
                  onGeofencingStart: () {},
                  onSettings: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
