import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';

class HealthSnapshotHistoryScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleTitle;

  const HealthSnapshotHistoryScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleTitle,
  });

  @override
  State<HealthSnapshotHistoryScreen> createState() =>
      _HealthSnapshotHistoryScreenState();
}

class _HealthSnapshotHistoryScreenState
    extends State<HealthSnapshotHistoryScreen> {
  List<Map<String, dynamic>> snapshots = [];
  bool loading = true;
  String? error;

  Future<void> loadSnapshots() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.get(
      '/vehicle/${widget.vehicleId}/health-snapshots',
      auth: true,
    );

    if (res.statusCode != 200) {
      setState(() {
        loading = false;
        error = 'Failed to load health snapshot history';
      });
      return;
    }

    try {
      final data = jsonDecode(res.body) as List;
      setState(() {
        snapshots = data.map((e) => Map<String, dynamic>.from(e)).toList();
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'Invalid health snapshot data received';
      });
    }
  }

  Future<void> deleteSnapshot(int snapshotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Snapshot'),
        content: const Text(
          'Are you sure you want to delete this health snapshot?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await Api.delete(
      '/vehicle/${widget.vehicleId}/health-snapshots/$snapshotId',
      auth: true,
    );

    if (res.statusCode == 200) {
      loadSnapshots();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete health snapshot')),
    );
  }

  @override
  void initState() {
    super.initState();
    loadSnapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Health Snapshot History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: loadSnapshots,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (snapshots.isEmpty)
              _emptyState()
            else
              ...snapshots.map(
                (snapshot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _snapshotCard(snapshot),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B5CF6),
        foregroundColor: const Color(0xFFE5E7EB),
        onPressed: () async {
          final changed = await Navigator.pushNamed(
            context,
            '/add-log',
            arguments: {
              'vehicleId': widget.vehicleId,
              'vehicleTitle': widget.vehicleTitle,
            },
          );

          if (changed == true) {
            loadSnapshots();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Snapshot'),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0x11000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.vehicleTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review previous manual vehicle health snapshots.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.health_and_safety_outlined, size: 48, color: Colors.black45),
          SizedBox(height: 12),
          Text(
            'No health snapshots yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first snapshot to start tracking health trends.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _snapshotCard(Map<String, dynamic> snapshot) {
    final id = snapshot['id'] as int;
    final mileage = snapshot['mileage']?.toString() ?? '--';
    final fuelLevel = snapshot['fuel_level']?.toString();
    final engineTemp = snapshot['engine_temp']?.toString();
    final batteryStatus = snapshot['battery_status']?.toString();
    final tireStatus = snapshot['tire_status']?.toString();
    final brakeStatus = snapshot['brake_status']?.toString();
    final notes = snapshot['notes']?.toString();
    final createdAt = snapshot['created_at']?.toString();
    final cel = snapshot['check_engine_light'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0x11000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cel ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  cel ? Icons.warning_amber_rounded : Icons.health_and_safety,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cel ? 'Attention Needed' : 'Healthy Snapshot',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => deleteSnapshot(id),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Snapshot',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              _chip(Icons.speed, '$mileage km'),
              _chip(Icons.warning_amber, 'CEL: ${cel ? "On" : "Off"}'),
              if (fuelLevel != null) _chip(Icons.local_gas_station, '$fuelLevel%'),
              if (engineTemp != null) _chip(Icons.thermostat, '$engineTemp°C'),
              if (batteryStatus != null) _chip(Icons.battery_full, batteryStatus),
              if (tireStatus != null) _chip(Icons.tire_repair, tireStatus),
              if (brakeStatus != null) _chip(Icons.car_repair, brakeStatus),
            ],
          ),
          if (notes != null && notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              notes,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
          if (createdAt != null && createdAt.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recorded: $createdAt',
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}