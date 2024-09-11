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
  static const platform = MethodChannel('com.amroid.parent_control/app_usage');

  ChildHomeCubit(this.childId) : super(ChildHomeInitial());

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
          Map<String, dynamic> appData = settingsSnapshot['apps'];
          appData.forEach((key, value) {
            bool isLocked = value['isLocked'] || value['usage'] >= value['usageLimit'];
            apps.add(App(
              packageName: key,
              appName: value['appName'],
              isLocked: isLocked,
              usage: value['usage'],
              usageLimit: value['usageLimit'],
            ));
          });
        }

        emit(ChildHomeLoaded(apps));
      } else {
        emit(ChildHomeError('Child not found'));
      }
    } catch (e) {
      emit(ChildHomeError(e.toString()));
    }
  }

  Future<void> getAppUsageData() async {
    try {
      final appUsageData = await platform.invokeMethod('getAppUsageData');
      // Process and push app usage data to Firebase
      await pushAppData(appUsageData);
    } on PlatformException catch (e) {
      print("Failed to get app usage data: '${e.message}'.");
    }
  }

  Future<void> pushAppData(dynamic appData) async {
    try {
      DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .collection('settings')
          .doc('apps')
          .get();

      Map<String, dynamic> existingApps = settingsSnapshot.exists ? settingsSnapshot.data() as Map<String, dynamic> : {};
      appData.forEach((key, value) {
        if (existingApps.containsKey(key)) {
          // Update existing app data
          existingApps[key]['usage'] = value['totalTimeInForeground'];
        } else {
          // Add new app data
          existingApps[key] = {
            'appName': key,
            'isLocked': false,
            'usage': value['totalTimeInForeground'],
            'usageLimit': 0,
          };
        }
      });

      await FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .collection('settings')
          .doc('apps')
          .set({'apps': existingApps}, SetOptions(merge: true));
    } catch (e) {
      print('Error pushing app data: $e');
    }
  }
}