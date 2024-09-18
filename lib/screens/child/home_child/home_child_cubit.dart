import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:parent_control/common/app_state.dart';
import 'package:usage_stats/usage_stats.dart';
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
  final  platform = const MethodChannel('com.amroid.parent_control/app_usage');

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
          Map<String, dynamic> appData = settingsSnapshot.data() as Map<String, dynamic>;
          List<App> result = appData.entries.map((entry) {
            return App(
              packageName: entry.key ?? "",
              appName: entry.value['appName'] ?? "",
              isLocked: entry.value['locked'] ?? false,
              usage: entry.value['usage'] ?? 0,
              usageLimit: entry.value['usageLimit'] ?? 0,
              currentTimeInMilli: entry.value['currentTimeInMilli'] ?? 0,
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

  Future<void> getAppUsageData() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 1));

      final queryUsageStats = await AppManager.queryUsageStats(startDate, endDate);
      final installedApps = await AppManager.getInstalledPackages();

      // Combine installed apps with usage stats
      final combinedApps = installedApps.map((installedApp) {
        final usageInfo = queryUsageStats.firstWhere(
              (usage) => usage.packageName == installedApp.packageName,
          orElse: () => UsageInfo(packageName: installedApp.packageName, totalTimeInForeground: "0"),
        );
        return App(
          packageName: installedApp.packageName,
          appName: installedApp.name,
          isLocked: false,
          usage: int.tryParse(usageInfo.totalTimeInForeground!)! ~/ 60000,
          usageLimit: 0,
          currentTimeInMilli: 0
        );
      }).toList();

      await pushAppData(combinedApps);
    } catch (e) {
      print("Failed to get app usage data: '${e.toString()}'.");
    }
  }

  Future<void> pushAppData(List<App> appData) async {
    try {
      DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .collection('settings')
          .doc('apps')
          .get();

      Map<String, dynamic> existingApps = settingsSnapshot.exists ? settingsSnapshot.data() as Map<String, dynamic> : {};
      appData.forEach((app) {
        if (existingApps.containsKey(app.packageName)) {
          // Update existing app data
          existingApps[app.packageName]['usage'] = app.usage;
        } else {
          // Add new app data
          existingApps[app.packageName] = {
            'appName': app.appName,
            'isLocked': app.isLocked,
            'usage': app.usage,
            'usageLimit': app.usageLimit,
          };
        }
      });

      await FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .collection('settings')
          .doc('apps')
          .set(existingApps);
    } catch (e) {
      print('Error pushing app data: $e');
    }
  }

  Future<void> startForegroundService() async {
    /*if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.restartService();
    } else {
      startForegroundTask();
    }*/
    try {
      await platform.invokeMethod('startAppUsageService', {'childId': childId});
    } on PlatformException catch (e) {
      print("Failed to start app usage service: '${e.message}'.");
    }
  }

  void startForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service',
        channelDescription: 'This notification appears when the foreground service is running.',
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
      ),
    );

    FlutterForegroundTask.startService(
      notificationTitle: 'Foreground Service',
      notificationText: 'Running...',
      callback: startCallback,
    );
  }

  void startCallback() {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('children').doc(childId).collection('settings').doc('apps');
    print("hhhhhhhhhhhh");

    // Periodic task to run every 5 minutes
    Timer.periodic(Duration(minutes: 5), (timer) async {
      await getAppUsageData();
      await checkAndUpdateUsageLimits();
    });

    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> appData = snapshot.data() as Map<String, dynamic>;
        appData?.forEach((packageName, appData) {
          final isLocked = appData['isLocked'] as bool? ?? false;
          final usage = appData['usage'] as int? ?? 0;
          final usageLimit = appData['usageLimit'] as int? ?? 0;

          if (isLocked) {
            lockApp(packageName);
          }
        });
      }
    }, onError: (error) {
      print('Error listening to Firebase: $error');
    });
  }

  Future<void> checkAndUpdateUsageLimits() async {
    try {
      DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .collection('settings')
          .doc('apps')
          .get();

      if (settingsSnapshot.exists) {
        Map<String, dynamic> appData = settingsSnapshot.data() as Map<String, dynamic>;
        bool hasChanges = false;

        appData.forEach((packageName, appData) {
          final usage = appData['usage'] as int? ?? 0;
          final usageLimit = appData['usageLimit'] as int? ?? 0;

          if (usage >= usageLimit && !appData['isLocked']) {
            appData['isLocked'] = true;
            hasChanges = true;
          }
        });

        if (hasChanges) {
          await FirebaseFirestore.instance
              .collection('children')
              .doc(childId)
              .collection('settings')
              .doc('apps')
              .update(appData);
        }
      }
    } catch (e) {
      print('Error checking and updating usage limits: $e');
    }
  }

  Future<void> lockApp(String packageName) async {
    try {
      // Implement the logic to lock the app using the DevicePolicyManager or other means
      // This part will depend on how you want to implement app locking in Flutter
    } catch (e) {
      print("Failed to lock app: '${e.toString()}'.");
    }
  }

  Future<void> requestUsageStatsPermission() async {
    if (!await AppManager.checkUsagePermission()) {
      await AppManager.requestUsagePermission();
    }
  }
}