import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class MockBluetoothService implements AppBluetoothService {
  MockBluetoothService._(); // private constructor
  static final instance = MockBluetoothService._();

  final StreamController<bool> _isScanningController = StreamController<bool>.broadcast();
  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionStateController = StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<BluetoothDevice?> _connectedDeviceController = StreamController<BluetoothDevice?>.broadcast();
  final StreamController<String> _receivedDataController = StreamController<String>.broadcast();

  @override
  Stream<bool> get isScanning => _isScanningController.stream;

  @override
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  @override
  Stream<BluetoothConnectionState> get connectionState => _connectionStateController.stream;

  @override
  Stream<BluetoothDevice?> get connectedDevice => _connectedDeviceController.stream;

  @override
  Stream<String> get receivedData => _receivedDataController.stream;

  @override
  Future<void> startScan() async {
    _isScanningController.add(true);
    await Future.delayed(const Duration(seconds: 2));
    _scanResultsController.add([
      ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('00:11:22:33:44:55'), platformName: 'ESP32-SOS'),
        advertisementData: AdvertisementData(advName: 'ESP32-SOS'),
        rssi: -50,
        timeStamp: DateTime.now(),
      ),
      ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('66:77:88:99:AA:BB'), platformName: 'Other Device'),
        advertisementData: AdvertisementData(advName: 'Other Device'),
        rssi: -60,
        timeStamp: DateTime.now(),
      ),
    ]);
    _isScanningController.add(false);
  }

  @override
  Future<void> stopScan() async {
    _isScanningController.add(false);
  }

  @override
  Future<void> connect(BluetoothDevice device) async {
    _connectionStateController.add(BluetoothConnectionState.connecting);
    await Future.delayed(const Duration(seconds: 2));
    _connectionStateController.add(BluetoothConnectionState.connected);
    _connectedDeviceController.add(device);
  }

  @override
  Future<void> disconnect() async {
    _connectionStateController.add(BluetoothConnectionState.disconnecting);
    await Future.delayed(const Duration(seconds: 1));
    _connectionStateController.add(BluetoothConnectionState.disconnected);
    _connectedDeviceController.add(null);
  }

  @override
  Future<void> sendData(String data) async {
    // Simulate sending data
  }
}