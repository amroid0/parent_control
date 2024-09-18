import 'dart:ffi';

class App {
  final String packageName;
  final String appName;
  final bool isLocked;
  final int usage;
  final int usageLimit;
  final int currentTimeInMilli;

  App({
    required this.packageName,
    required this.appName,
    required this.isLocked,
    required this.usage,
    required this.usageLimit, // in minutes
    required this.currentTimeInMilli
// Add this field
  });
}