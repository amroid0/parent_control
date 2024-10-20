import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cubit/geo_cubit.dart';
import '../cubit/geofencing_state.dart';

class GeofencingScreen extends StatelessWidget {
  final LatLng safeZoneCenter;
  final double safeZoneRadius;

  const GeofencingScreen({
    super.key,
    required this.safeZoneCenter,
    required this.safeZoneRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofencing'),
      ),
      body: BlocProvider(
        create: (_) => GeofencingCubit(
          safeZoneCenter: safeZoneCenter,
          safeZoneRadius: safeZoneRadius,
        ),
        child: const GeofencingView(),
      ),
    );
  }
}

class GeofencingView extends StatelessWidget {
  const GeofencingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeofencingCubit, GeofencingState>(
      builder: (context, state) {
        if (state is GeofencingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GeofencingInsideZone) {
          return const Center(child: Text('Child is inside the safe zone'));
        } else if (state is GeofencingOutsideZone) {
          return const Center(child: Text('Child is outside the safe zone'));
        }
        return const Center(child: Text('Get your child location'));
      },
    );
  }
}
