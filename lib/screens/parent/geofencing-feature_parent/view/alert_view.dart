import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/alert_cubit.dart';
import '../cubit/alert_settings_cubit.dart';


class AlertSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إعدادات التنبيهات')),
      body: BlocProvider(
        create: (_) => AlertSettingsCubit(),
        child: AlertSettingsView(),
      ),
    );
  }
}

class AlertSettingsView extends StatefulWidget {
  @override
  _AlertSettingsViewState createState() => _AlertSettingsViewState();
}

class _AlertSettingsViewState extends State<AlertSettingsView> {
  bool _sendPushNotification = true;
  bool _sendSMS = false;
  bool _sendEmail = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text('إشعارات (Push Notification)'),
            value: _sendPushNotification,
            onChanged: (value) {
              setState(() {
                _sendPushNotification = value!;
              });
            },
          ),
          CheckboxListTile(
            title: Text('رسائل (SMS)'),
            value: _sendSMS,
            onChanged: (value) {
              setState(() {
                _sendSMS = value!;
              });
            },
          ),
          CheckboxListTile(
            title: Text('بريد إلكتروني (Email)'),
            value: _sendEmail,
            onChanged: (value) {
              setState(() {
                _sendEmail = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              // حفظ الإعدادات باستخدام Cubit
              context.read<AlertSettingsCubit>().saveAlertSettings(
                    _sendPushNotification,
                    _sendSMS,
                    _sendEmail,
                  );
            },
            child: Text('حفظ الإعدادات'),
          ),
          BlocBuilder<AlertSettingsCubit, AlertSettingsState>(
            builder: (context, state) {
              if (state is AlertSettingsSaved) {
                return Text('تم حفظ الإعدادات بنجاح');
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
