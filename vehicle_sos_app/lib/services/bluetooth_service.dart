import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SystemData {
  final int battery;
  final bool isEmergency;
  final bool gpsSignal;
  final bool sensorStatus;
  final int alertsCount;

  SystemData({
    required this.battery,
    required this.isEmergency,
    required this.gpsSignal,
    required this.sensorStatus,
    required this.alertsCount,
  });
}

abstract class AppBluetoothService {
  Stream<bool> get isScanning;
  Stream<List<ScanResult>> get scanResults;
  Stream<BluetoothConnectionState> get connectionState;
  Stream<BluetoothDevice?> get connectedDevice;
  Stream<SystemData> get systemData;

  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(BluetoothDevice device);
  Future<void> disconnect();
  Future<void> sendData(String data);
}

class FlutterBluePlusService implements AppBluetoothService {
  FlutterBluePlusService._(); // private constructor
  static final instance = FlutterBluePlusService._();

  final StreamController<SystemData> _systemDataController = StreamController<SystemData>.broadcast();
  final StreamController<BluetoothDevice?> _connectedDeviceController = StreamController<BluetoothDevice?>.broadcast();
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _valueSubscription;

  @override
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  @override
  Stream<BluetoothConnectionState> get connectionState => _connectedDevice != null
      ? _connectedDevice!.connectionState
      : Stream.value(BluetoothConnectionState.disconnected);

  @override
  Stream<BluetoothDevice?> get connectedDevice => _connectedDeviceController.stream;

  @override
  Stream<SystemData> get systemData => _systemDataController.stream;

  @override
  Future<void> startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
    _connectedDevice = device;
    _connectedDeviceController.add(device);
    _discoverServices();
  }

  @override
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _connectedDeviceController.add(null);
    _valueSubscription?.cancel();
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;
    final services = await _connectedDevice!.discoverServices();
    final serviceUuid = Guid("12345678-1234-1234-1234-1234567890ab");
    final characteristicUuid = Guid("abcd1234-5678-90ab-cdef-1234567890ab");

    for (final service in services) {
      if (service.uuid == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid == characteristicUuid &&
              characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            _valueSubscription = characteristic.value.listen((value) {
              final dataString = String.fromCharCodes(value);
              final parts = dataString.split(',');
              if (parts.length == 5) {
                final systemData = SystemData(
                  battery: int.tryParse(parts[0]) ?? 0,
                  isEmergency: (int.tryParse(parts[1]) ?? 0) == 1,
                  gpsSignal: (int.tryParse(parts[2]) ?? 0) == 1,
                  sensorStatus: (int.tryParse(parts[3]) ?? 0) == 1,
                  alertsCount: int.tryParse(parts[4]) ?? 0,
                );
                _systemDataController.add(systemData);
              }
            });
          }
        }
      }
    }
  }

  @override
  Future<void> sendData(String data) async {
    if (_connectedDevice == null) return;
    final services = await _connectedDevice!.discoverServices();
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          await characteristic.write(data.codeUnits);
        }
      }
    }
  }
}