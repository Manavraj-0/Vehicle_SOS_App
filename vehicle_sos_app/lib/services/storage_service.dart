import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._(); // private constructor
  static final instance = StorageService._();

  static const _contactsKey = 'emergency_contacts';
  static const _lastConnectedDeviceKey = 'last_connected_device';

  Future<void> saveContacts(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = jsonEncode(contacts);
    await prefs.setString(_contactsKey, contactsJson);
  }

  Future<List<Map<String, String>>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString(_contactsKey);
    if (contactsJson != null) {
      final contacts = jsonDecode(contactsJson) as List;
      return contacts.map((contact) => Map<String, String>.from(contact)).toList();
    }
    return [];
  }

  Future<void> saveLastConnectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastConnectedDeviceKey, deviceId);
  }

  Future<String?> getLastConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastConnectedDeviceKey);
  }
}