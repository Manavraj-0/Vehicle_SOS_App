import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoEmergencyCall = true;
  bool gpsTracking = true;
  bool fireDetection = true;
  bool crashDetection = true;
  bool voiceAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSwitch('Auto Emergency Call', autoEmergencyCall, (value) {
            setState(() => autoEmergencyCall = value);
          }),
          _buildSettingsSwitch('GPS Tracking', gpsTracking, (value) {
            setState(() => gpsTracking = value);
          }),
          _buildSettingsSwitch('Fire Detection', fireDetection, (value) {
            setState(() => fireDetection = value);
          }),
          _buildSettingsSwitch('Crash Detection', crashDetection, (value) {
            setState(() => crashDetection = value);
          }),
          _buildSettingsSwitch('Voice Alerts', voiceAlerts, (value) {
            setState(() => voiceAlerts = value);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }
}