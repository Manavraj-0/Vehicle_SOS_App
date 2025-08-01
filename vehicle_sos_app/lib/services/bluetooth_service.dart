import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class AppBluetoothService {
  Stream<bool> get isScanning;
  Stream<List<ScanResult>> get scanResults;
  Stream<BluetoothConnectionState> get connectionState;
  Stream<BluetoothDevice?> get connectedDevice;
  Stream<String> get receivedData;

  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(BluetoothDevice device);
  Future<void> disconnect();
  Future<void> sendData(String data);
}

class FlutterBluePlusService implements AppBluetoothService {
  FlutterBluePlusService._(); // private constructor
  static final instance = FlutterBluePlusService._();

  final StreamController<String> _receivedDataController = StreamController<String>.broadcast();
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
  Stream<String> get receivedData => _receivedDataController.stream;

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
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);
          _valueSubscription = characteristic.value.listen((value) {
            _receivedDataController.add(String.fromCharCodes(value));
          });
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