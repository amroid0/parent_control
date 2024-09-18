import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';

class AppManager {
  static Future<bool> checkUsagePermission() async {
    try {
      return await UsageStats.checkUsagePermission()?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestUsagePermission() async {
    try {
      await UsageStats.grantUsagePermission();
    } on PlatformException catch (e) {
      print("Failed to request usage permission: '${e.message}'.");
    }
  }

  static Future<List<UsageInfo>> queryUsageStats(DateTime startDate, DateTime endDate) async {
    try {
      return await UsageStats.queryUsageStats(startDate, endDate);
    } on PlatformException catch (e) {
      print("Failed to query usage stats: '${e.message}'.");
      return [];
    }
  }



 static Future<List<AppInfo>> getInstalledPackages() async {
   var status = await Permission.storage.status;

   // If not granted, request permission
   if (!status.isGranted) {
     await Permission.storage.request();
   }
   return  await InstalledApps.getInstalledApps(
      true,false
  );

  }

}