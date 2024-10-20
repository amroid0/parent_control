import 'package:bloc/bloc.dart';

import '../../model/alert.dart';
import 'alert_settings_state.dart';

class AlertSettingsCubit extends Cubit<AlertSettingsState> {
  AlertSettingsCubit() : super(AlertSettingsInitial());

  void saveAlertSettings(bool push, bool sms, bool email) {
    emit(AlertSettingsSaved(
      AlertSettings(sendPushNotification: push, sendSMS: sms, sendEmail: email),
    ));
  }
}
