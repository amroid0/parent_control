import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChildLocationsState {}

class ChildLocationsInitial extends ChildLocationsState {}

class ChildLocationsLoading extends ChildLocationsState {}

class ChildLocationsLoaded extends ChildLocationsState {
  final Map<String, GeoPoint> locations;
  final Map<String, String> childNames;

  ChildLocationsLoaded(this.locations, this.childNames);
}

class ChildLocationsError extends ChildLocationsState {
  final String error;

  ChildLocationsError(this.error);
}

class SafeZoneUpdated extends ChildLocationsState {
  final String childId;
  final GeoPoint safeZoneCenter;
  final double radius;

  SafeZoneUpdated(this.childId, this.safeZoneCenter, this.radius);
}

class ChildLocationsCubit extends Cubit<ChildLocationsState> {
  ChildLocationsCubit(this.parentId) : super(ChildLocationsInitial());

  final String parentId;
  final Map<String, StreamSubscription<DocumentSnapshot>> _subscriptions = {};

  void listenToLocations() async {
    emit(ChildLocationsLoading());
    try {
      DocumentSnapshot parentSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .get();

      if (parentSnapshot.exists) {
        List<String> childIds = List<String>.from(parentSnapshot['childIds']);
        if (childIds.isEmpty) {
          emit(ChildLocationsLoaded({}, {}));
          return;
        }

        Map<String, GeoPoint> locations = {};
        Map<String, String> childNames = {};

        void onLocationUpdate(String childId, DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            final latitude = data['latitude'];
            final longitude = data['longitude'];
            locations[childId] = GeoPoint(latitude, longitude);
          } else {
            locations[childId] = const GeoPoint(0, 0);
          }

          if (locations.length == childIds.length &&
              childNames.length == childIds.length) {
            emit(ChildLocationsLoaded(locations, childNames));
          }
        }

        List<Future<void>> nameFutures = [];

        for (String childId in childIds) {
          _subscriptions[childId]?.cancel();
          _subscriptions[childId] = FirebaseFirestore.instance
              .collection('children')
              .doc(childId)
              .collection('locations')
              .doc('latest')
              .snapshots()
              .listen((snapshot) {
            onLocationUpdate(childId, snapshot);
          }, onError: (error) {
            emit(ChildLocationsError(error.toString()));
          });

          nameFutures.add(FirebaseFirestore.instance
              .collection('children')
              .doc(childId)
              .get()
              .then((childSnapshot) {
            if (childSnapshot.exists) {
              childNames[childId] = childSnapshot['name'];
            }
          }));
        }

        await Future.wait(nameFutures);

        if (locations.length == childIds.length &&
            childNames.length == childIds.length) {
          emit(ChildLocationsLoaded(locations, childNames));
        }
      }
    } catch (e) {
      emit(ChildLocationsError(e.toString()));
    }
  }

  void updateSafeZone(String childId, GeoPoint center, double radius) {
    FirebaseFirestore.instance.collection('children').doc(childId).update({
      'safeZoneCenter': center,
      'safeZoneRadius': radius,
    }).then((_) {
      emit(SafeZoneUpdated(childId, center, radius));
    }).catchError((error) {
      emit(ChildLocationsError(error.toString()));
    });
  }

  @override
  Future<void> close() {
    _subscriptions.forEach((childId, subscription) {
      subscription.cancel();
    });
    return super.close();
  }

  Map<String, GeoPoint> toMap(Iterable<MapEntry<String, GeoPoint>> entries) {
    return {for (var entry in entries) entry.key: entry.value};
  }

  void searchChildByName(String query) {
    if (state is ChildLocationsLoaded) {
      final loadedState = state as ChildLocationsLoaded;
      final filteredLocations = loadedState.locations.entries.where((entry) {
        final childName = loadedState.childNames[entry.key] ?? '';
        return childName.toLowerCase().contains(query.toLowerCase());
      });

      final filteredLocationsMap = toMap(filteredLocations);

      emit(ChildLocationsLoaded(filteredLocationsMap, loadedState.childNames));
    }
  }
}
