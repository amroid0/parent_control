import '../model/alert.dart';

abstract class AlertSettingsState {}

class AlertSettingsInitial extends AlertSettingsState {}

class AlertSettingsSaved extends AlertSettingsState {
  final AlertSettings settings;

  AlertSettingsSaved(this.settings);
}
