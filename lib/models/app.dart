class App {
  final String packageName;
  final String appName;
  final bool isLocked;
  final int usage;
  final int usageLimit; // Add this field

  App({
    required this.packageName,
    required this.appName,
    required this.isLocked,
    required this.usage,
    required this.usageLimit, // Add this field
  });
}