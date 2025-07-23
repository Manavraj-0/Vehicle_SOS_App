

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:vehicle_sos_app/ui/dashboard_screen.dart';
import 'package:vehicle_sos_app/ui/alerts_screen.dart';
import 'package:vehicle_sos_app/ui/contacts_screen.dart';
import 'package:vehicle_sos_app/ui/settings_screen.dart';
import 'dart:async'; // For Timer
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const VehicleSOSApp());
}

class VehicleSOSApp extends StatelessWidget {
  const VehicleSOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle SOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Centralized State Variables
  bool _isConnected = true;
  double _systemBattery = 92.0;
  bool _isEmergencyMode = false;
  String _vehicleLocation = 'Unknown Location';
  List<Map<String, String>> _emergencyContacts = [
    {'id': '1', 'name': 'John Doe', 'phone': '+1234567890', 'relation': 'Family', 'removable': 'true'},
    {'id': '2', 'name': 'Jane Smith', 'phone': '+0987654321', 'relation': 'Emergency', 'removable': 'true'},
    {'id': '3', 'name': 'Police', 'phone': '911', 'relation': 'Emergency Service', 'removable': 'false'},
    {'id': '4', 'name': 'Ambulance', 'phone': '911', 'relation': 'Emergency Service', 'removable': 'false'},
    {'id': '5', 'name': 'Fire Department', 'phone': '911', 'relation': 'Emergency Service', 'removable': 'false'},
  ];
  List<Map<String, String>> _alerts = [
    {'id': '1', 'type': 'accident', 'location': 'Highway 101', 'time': '2 mins ago', 'status': 'active'},
    {'id': '2', 'type': 'fire', 'location': 'Main Street', 'time': '1 hour ago', 'status': 'resolved'}
  ];

  late Timer _batteryTimer;

  @override
  void initState() {
    super.initState();
    _batteryTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        _systemBattery = ((_systemBattery + ( (0.5 - (DateTime.now().millisecondsSinceEpoch % 1000) / 1000) * 0.5))).clamp(88.0, 100.0);
      });
    });
    _determinePosition();
  }

  @override
  void dispose() {
    _batteryTimer.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _vehicleLocation = '${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  void _handleEmergencyCall(BuildContext context) async {
    setState(() {
      _isEmergencyMode = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 Emergency Call Initiated!\nAttempting to call emergency contacts...')),
    );
    for (var contact in _emergencyContacts) {
      if (contact['relation'] == 'Emergency' || contact['relation'] == 'Emergency Service') {
        await _launchUrl('tel:${contact['phone']}');
      }
    }
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isEmergencyMode = false;
      });
    });
  }

  void _handleSendAlert(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📱 Alert Sent!\nAttempting to send SMS and WhatsApp messages...')),
    );
    String message = 'Emergency! My vehicle is at $_vehicleLocation. Please help!';
    for (var contact in _emergencyContacts) {
      if (contact['relation'] == 'Emergency' || contact['relation'] == 'Emergency Service') {
        await _launchUrl('sms:${contact['phone']}?body=$message');
        await _launchUrl('whatsapp://send?phone=${contact['phone']}&text=$message');
      }
    }
  }

  void _handleShareLocation(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📍 Location Shared!\nCurrent location: $_vehicleLocation\nAttempting to open Google Maps link.')),
    );
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=' + Uri.encodeComponent(_vehicleLocation);
    await _launchUrl(googleMapsUrl);
  }

  void _handleViewMap(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗺️ Opening Map View...\nAttempting to show real-time vehicle location and nearby emergency services.')),
    );
    String googleMapsUrl = 'https://www.google.com/maps/@?api=1&map_action=map&center=34.052235,-118.243683'; // Example coordinates for Los Angeles
    await _launchUrl(googleMapsUrl);
  }

  void _addNewContact(BuildContext context) {
    int personalContactsCount = _emergencyContacts.where((contact) => contact['removable'] == 'true').length;
    if (personalContactsCount >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 5 personal contacts.')),
      );
      return;
    }
    setState(() {
      _emergencyContacts.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'New Contact',
        'phone': '',
        'relation': 'Family',
        'removable': 'true'
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('👤 New Contact Added!\nPlease edit the contact details.')),
    );
  }

  void _updateContact(String id, String name, String phone, String relation) {
    setState(() {
      int index = _emergencyContacts.indexWhere((contact) => contact['id'] == id);
      if (index != -1) {
        _emergencyContacts[index]['name'] = name;
        _emergencyContacts[index]['phone'] = phone;
        _emergencyContacts[index]['relation'] = relation;
      }
    });
  }

  void _deleteContact(String id) {
    setState(() {
      _emergencyContacts.removeWhere((contact) => contact['id'] == id && contact['removable'] == 'true');
    });
  }

  void _callContact(BuildContext context, Map<String, String> contact) async {
    await _launchUrl('tel:${contact['phone']}');
  }

  void _messageContact(BuildContext context, Map<String, String> contact) async {
    String message = 'Emergency! My vehicle is at $_vehicleLocation. Please help!';
    await _launchUrl('sms:${contact['phone']}?body=$message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            DashboardScreen(
              isConnected: _isConnected,
              systemBattery: _systemBattery,
              isEmergencyMode: _isEmergencyMode,
              alertsCount: _alerts.where((alert) => alert['status'] == 'active').length,
              toggleConnection: _toggleConnection,
              handleEmergencyCall: () => _handleEmergencyCall(context),
              handleSendAlert: () => _handleSendAlert(context),
              handleShareLocation: () => _handleShareLocation(context),
              handleViewMap: () => _handleViewMap(context),
            ),
            AlertsScreen(alerts: _alerts),
            ContactsScreen(
              emergencyContacts: _emergencyContacts,
              addNewContact: () => _addNewContact(context),
              updateContact: _updateContact,
              deleteContact: _deleteContact,
              callContact: (contact) => _callContact(context, contact),
              messageContact: (contact) => _messageContact(context, contact),
            ),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.house),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.triangle_alert),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
