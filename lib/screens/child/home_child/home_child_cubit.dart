import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../../models/app.dart';

abstract class ChildHomeState {}

class ChildHomeInitial extends ChildHomeState {}

class ChildHomeLoading extends ChildHomeState {}

class ChildHomeLoaded extends ChildHomeState {
  final List<App> apps;

  ChildHomeLoaded(this.apps);
}

class ChildHomeError extends ChildHomeState {
  final String error;

  ChildHomeError(this.error);
}

class ChildHomeCubit extends Cubit<ChildHomeState> {
  final String childId;
  final platform = const MethodChannel('com.amroid.parent_control/app_usage');
  late StreamSubscription<DocumentSnapshot> _firestoreSubscription;

  ChildHomeCubit(this.childId) : super(ChildHomeInitial()) {
    _setupFirestoreListener();
  }
  Future<void> startForegroundService() async {
    try {
      await platform.invokeMethod('startAppUsageService', {'childId': childId});
    } on PlatformException catch (e) {
      print("Failed to start app usage service: '${e.message}'.");
    }
  }

  Future<void> fetchApps() async {
    emit(ChildHomeLoading());
    try {
      DocumentSnapshot childSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .get();

      if (childSnapshot.exists) {
        List<App> apps = [];

        DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance
            .collection('children')
            .doc(childId)
            .collection('settings')
            .doc('apps')
            .get();

        if (settingsSnapshot.exists) {
          Map<String, dynamic> appData =
              settingsSnapshot.data() as Map<String, dynamic>;
          List<App> result = appData.entries.map((entry) {
            return App(
              packageName: entry.key ?? "",
              appName: entry.value['appName'] ?? "",
              isLocked: entry.value['locked'] ?? false,
              usage: entry.value['usage'] ?? 0,
              usageLimit: entry.value['usageLimit'] ?? 0,
              currentTimeInMilli: entry.value['currentTimeInMilli'] ?? 0,
              iconUrl: entry.value['iconUrl'] ?? "",
            );
          }).toList();

          // Sort apps by usage (descending) and then by locked status (locked first)
          result.sort((a, b) {
            if (a.isLocked && !b.isLocked) {
              return -1;
            } else if (!a.isLocked && b.isLocked) {
              return 1;
            } else {
              return b.usage.compareTo(a.usage);
            }
          });
          apps.addAll(result);
        }

        emit(ChildHomeLoaded(apps));
      } else {
        emit(ChildHomeError('Child not found'));
      }
    } catch (e) {
      emit(ChildHomeError(e.toString()));
    }
  }

  void _setupFirestoreListener() {
    FirebaseFirestore.instance
        .collection('children')
        .doc(childId)
        .collection('settings')
        .doc('apps')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _processAppData(snapshot.data() as Map<String, dynamic>);
      } else {
        emit(ChildHomeError('No apps found'));
      }
    }, onError: (error) {
      emit(ChildHomeError(error.toString()));
    });
  }

  void _processAppData(Map<String, dynamic> appData) {
    List<App> apps = appData.entries.map((entry) {
      return App(
        packageName: entry.key ?? "",
        appName: entry.value['appName'] ?? "",
        isLocked: entry.value['locked'] ?? false,
        usage: entry.value['usage'] ?? 0,
        usageLimit: entry.value['usageLimit'] ?? 0,
        currentTimeInMilli: entry.value['currentTimeInMilli'] ?? 0,
        iconUrl: entry.value['iconUrl'] ?? "",
      );
    }).toList();

    // Sort apps by usage (descending) and then by locked status (locked first)
    apps.sort((a, b) {
      if (a.isLocked && !b.isLocked) {
        return -1;
      } else if (!a.isLocked && b.isLocked) {
        return 1;
      } else {
        return b.usage.compareTo(a.usage);
      }
    });

    emit(ChildHomeLoaded(apps));
  }

  @override
  Future<void> close() {
    _firestoreSubscription.cancel();
    return super.close();
  }
}
