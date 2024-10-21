import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parent_control/screens/parent/home_parent/widgets/location%20tap%20all%20widgets/child_card_location.dart';
import '../../../../core/utils/app_images.dart';
import '../location_child_cubit.dart';
import 'location tap all widgets/map.dart';
import 'location tap all widgets/search_for_child.dart';

class LocationsTab extends StatelessWidget {
  const LocationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController = Completer();
    final String parentId = FirebaseAuth.instance.currentUser!.uid;
    return BlocProvider(
      create: (context) => ChildLocationsCubit(parentId)..listenToLocations(),
      child: BlocBuilder<ChildLocationsCubit, ChildLocationsState>(
        builder: (context, state) {
          if (state is ChildLocationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChildLocationsLoaded) {
            return Column(
              children: [
                SearchBarChild(onSearch: (query) {
                  context.read<ChildLocationsCubit>().searchChildByName(query);
                }),
                Expanded(
                  child: ChildLocationsMap(
                    mapController: mapController,
                    locations: state.locations,
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.locations.length,
                    itemBuilder: (context, index) {
                      final childId = state.locations.keys.elementAt(index);
                      final location = state.locations[childId]!;
                      final childName = state.childNames[childId]!;

                      return ChildCard(
                        childId: childId,
                        childName: childName,
                        location: location,
                        mapController: mapController,
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ChildLocationsError) {
            return Center(child: Text(state.error));
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
