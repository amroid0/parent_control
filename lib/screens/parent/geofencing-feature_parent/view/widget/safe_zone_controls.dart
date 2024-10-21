import 'package:flutter/material.dart';
import '../../../widgets/custom_icon_button.dart';

class SafeZoneControls extends StatelessWidget {
  final double safeZoneRadius;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onSave;
  final VoidCallback onGeofencingStart;
  final VoidCallback onSettings;

  const SafeZoneControls({
    super.key,
    required this.safeZoneRadius,
    required this.onRadiusChanged,
    required this.onSave,
    required this.onGeofencingStart,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          value: safeZoneRadius,
          min: 50,
          max: 500,
          divisions: 10,
          label: '${safeZoneRadius.toStringAsFixed(0)} Meters',
          onChanged: onRadiusChanged,
        ),
        Text(
          'Safe Zone Radius: ${safeZoneRadius.toStringAsFixed(0)} Meters',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomIconButton(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: 'Save Zone',
            ),
            CustomIconButton(
              onPressed: onGeofencingStart,
              icon: const Icon(Icons.location_on),
              label: 'Start Geofencing',
            ),
          ],
        ),
        CustomIconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
