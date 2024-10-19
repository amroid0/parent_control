import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/geo_cubit.dart';
import '../cubit/geo_state.dart';
import '../../../parent/geofencing-feature_parent/cubit/geo_parent_cubit.dart';
import '../../../parent/geofencing-feature_parent/view/add_geo_parent.dart';

class CheckGeoChild extends StatelessWidget {
  const CheckGeoChild({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Child Home")),
        body: MultiBlocProvider(
          providers: ([
            BlocProvider(create: (context) => GeofenceCubit()),
          ]),
          child: BlocProvider(
            create: (context) => GeofenceChildCubit(),
            child: BlocBuilder<GeofenceChildCubit, GeofenceChildState>(
              builder: (context, state) {
                if (state is GeofenceChildLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GeofenceChildLoaded) {
                  return _locationSuccess(context, state);
                } else if (state is GeofenceFailure) {
                  return _locationError(state.error);
                } else if (state is GeofenceChildInitial) {
                  return _initialUI(context);
                } else {
                  return const Center(child: Text("Unknown error occurred"));
                }
              },
            ),
          ),
        ));
  }

  Widget _initialUI(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read<GeofenceChildCubit>().getCurrentLocation(context);
        },
        child: const Text("Get My Location"),
      ),
    );
  }

  Widget _locationSuccess(BuildContext context, GeofenceChildLoaded state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Your location: ${state.latitude}, ${state.longitude}"),
        ElevatedButton(
          onPressed: () {},
          child: const Text("Go to Parent Page"),
        ),
      ],
    );
  }

  Widget _locationError(String error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
