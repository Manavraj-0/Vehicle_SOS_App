import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:vehicle_sos_app/services/bluetooth_service.dart';

class DashboardScreen extends StatefulWidget {
  final bool isConnected;
  final double systemBattery;
  final bool isEmergencyMode;
  final int alertsCount;
  final VoidCallback toggleConnection;
  final VoidCallback handleEmergencyCall;
  final VoidCallback handleSendAlert;
  final VoidCallback handleShareLocation;
  final VoidCallback handleViewMap;

  const DashboardScreen({
    super.key,
    required this.isConnected,
    required this.systemBattery,
    required this.isEmergencyMode,
    required this.alertsCount,
    required this.toggleConnection,
    required this.handleEmergencyCall,
    required this.handleSendAlert,
    required this.handleShareLocation,
    required this.handleViewMap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppBluetoothService _bluetoothService = FlutterBluePlusService.instance;
  SystemData _systemData = SystemData(
    battery: 0,
    isEmergency: false,
    gpsSignal: false,
    sensorStatus: false,
    alertsCount: 0,
  );
  StreamSubscription? _dataSubscription;

  @override
  void initState() {
    super.initState();
    _dataSubscription = _bluetoothService.systemData.listen((data) {
      setState(() {
        _systemData = data;
      });
    });
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Universal Vehicle Safety System',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      LucideIcons.shield,
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Connection Status
              _buildConnectionStatus(),
              const SizedBox(height: 20),

              // Status Cards
              _buildStatusCards(),
              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: StreamBuilder<BluetoothConnectionState>(
        stream: _bluetoothService.connectionState,
        initialData: BluetoothConnectionState.disconnected,
        builder: (context, snapshot) {
          final isConnected =
              snapshot.data == BluetoothConnectionState.connected;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SOS Device',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isConnected)
                    Row(
                      children: [
                        const Icon(LucideIcons.battery, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('${_systemData.battery}%'),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (isConnected) {
                        _bluetoothService.disconnect();
                      } else {
                        _showDeviceScanDialog();
                      }
                    },
                    child: Text(isConnected ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatusCard(
          LucideIcons.car,
          'Vehicle Status',
          _systemData.isEmergency ? 'SOS Active' : 'Protected',
          _systemData.isEmergency ? Colors.red : Colors.green,
          _systemData.isEmergency
              ? Colors.red.shade50
              : Colors.green.shade50,
        ),
        _buildStatusCard(
          LucideIcons.map_pin,
          'GPS Signal',
          _systemData.gpsSignal ? 'Strong' : 'Weak',
          _systemData.gpsSignal ? Colors.blue : Colors.grey,
          _systemData.gpsSignal ? Colors.blue.shade50 : Colors.grey.shade50,
        ),
        _buildStatusCard(
          LucideIcons.activity,
          'Sensors',
          _systemData.sensorStatus ? 'All Active' : 'Inactive',
          _systemData.sensorStatus ? Colors.purple : Colors.grey,
          _systemData.sensorStatus
              ? Colors.purple.shade50
              : Colors.grey.shade50,
        ),
        _buildStatusCard(
          LucideIcons.bell,
          'Alerts',
          _systemData.alertsCount.toString(),
          Colors.orange,
          Colors.orange.shade50,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    IconData icon,
    String title,
    String value,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildQuickActionButton(
                LucideIcons.phone,
                'Emergency Call',
                widget.isEmergencyMode ? Colors.red.shade700 : Colors.red,
                widget.handleEmergencyCall,
              ),
              _buildQuickActionButton(
                LucideIcons.message_square,
                'Send Alert',
                Colors.blue,
                widget.handleSendAlert,
              ),
              _buildQuickActionButton(
                LucideIcons.navigation,
                'Share Location',
                Colors.green,
                widget.handleShareLocation,
              ),
              _buildQuickActionButton(
                LucideIcons.map,
                'View Map',
                Colors.purple,
                widget.handleViewMap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showDeviceScanDialog() {
    _bluetoothService.startScan();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scan for Devices'),
          content: StreamBuilder<List<ScanResult>>(
            stream: _bluetoothService.scanResults,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final serviceUuid = Guid("12345678-1234-1234-1234-1234567890ab");
              final results = snapshot.data!
                  .where((r) => r.advertisementData.serviceUuids.contains(serviceUuid))
                  .toList();
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final deviceName =
                        result.advertisementData.advName.isNotEmpty
                            ? result.advertisementData.advName
                            : result.device.platformName.isNotEmpty
                                ? result.device.platformName
                                : 'Unknown Device';
                    return ListTile(
                      title: Text(deviceName),
                      subtitle: Text(result.device.remoteId.toString()),
                      onTap: () {
                        _bluetoothService.connect(result.device);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _bluetoothService.stopScan();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
