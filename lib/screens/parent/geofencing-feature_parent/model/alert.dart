class AlertSettings {
  final bool sendPushNotification;
  final bool sendSMS;
  final bool sendEmail;

  AlertSettings({
    required this.sendPushNotification,
    required this.sendSMS,
    required this.sendEmail,
  });
}

class GeofenceEvent {
  final String childId;
  final DateTime timestamp;
  final bool entered;

  GeofenceEvent({
    required this.childId,
    required this.timestamp,
    required this.entered,
  });
}
