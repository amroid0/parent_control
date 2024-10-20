import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/alert/alert_cubit.dart';
import '../cubit/alert/alert_settings_state.dart';

class AlertSettingsScreen extends StatelessWidget {
  const AlertSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Settings')),
      body: BlocProvider(
        create: (_) => AlertSettingsCubit(),
        child: const AlertSettingsView(),
      ),
    );
  }
}

class AlertSettingsView extends StatefulWidget {
  const AlertSettingsView({super.key});

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
            title: const Text('Notification'),
            value: _sendPushNotification,
            onChanged: (value) {
              setState(() {
                _sendPushNotification = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('SMS'),
            value: _sendSMS,
            onChanged: (value) {
              setState(() {
                _sendSMS = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Email'),
            value: _sendEmail,
            onChanged: (value) {
              setState(() {
                _sendEmail = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AlertSettingsCubit>().saveAlertSettings(
                    _sendPushNotification,
                    _sendSMS,
                    _sendEmail,
                  );
            },
            child: const Text('Save Settings'),
          ),
          BlocBuilder<AlertSettingsCubit, AlertSettingsState>(
            builder: (context, state) {
              if (state is AlertSettingsSaved) {
                return const Text('Settings saved successfully');
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
