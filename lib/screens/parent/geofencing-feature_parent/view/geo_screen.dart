import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cubit/geo_cubit.dart';
import '../cubit/geofencing_state.dart';

class GeofencingScreen extends StatelessWidget {
  final LatLng safeZoneCenter;
  final double safeZoneRadius;

  const GeofencingScreen({
    Key? key,
    required this.safeZoneCenter,
    required this.safeZoneRadius,
  }) : super(key: key);

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
        child: GeofencingView(),
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
          return const Center(child: const CircularProgressIndicator());
        } else if (state is GeofencingInsideZone) {
          return const Center(child: Text('الطفل داخل المنطقة الآمنة'));
        } else if (state is GeofencingOutsideZone) {
          return const Center(child: Text('الطفل خارج المنطقة الآمنة'));
        }
        return const Center(child: Text('جاري مراقبة الموقع...'));
      },
    );
  }
}
