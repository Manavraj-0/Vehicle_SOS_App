
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AlertsScreen extends StatelessWidget {
  final List<Map<String, String>> alerts;

  const AlertsScreen({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildAlertCard(
              alert['type']!,
              alert['location']!,
              alert['time']!,
              alert['status']!,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(String type, String location, String time, String status) {
    final bool isActive = status == 'active';
    final Color color = type == 'accident' ? Colors.red : Colors.orange;
    final IconData icon = type == 'accident' ? LucideIcons.triangle_alert : LucideIcons.flame;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == 'accident' ? 'Accident Detected' : 'Fire Detected',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(location, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Active' : 'Resolved',
                  style: TextStyle(
                    color: isActive ? Colors.red.shade800 : Colors.green.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
