import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleTitle;

  const MaintenanceHistoryScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleTitle,
  });

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;
  String? error;

  Future<void> loadRecords() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.get(
      '/vehicle/${widget.vehicleId}/maintenance-records',
      auth: true,
    );

    if (res.statusCode != 200) {
      setState(() {
        loading = false;
        error = 'Failed to load maintenance history';
      });
      return;
    }

    try {
      final data = jsonDecode(res.body) as List;
      setState(() {
        records = data.map((e) => Map<String, dynamic>.from(e)).toList();
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'Invalid maintenance data received';
      });
    }
  }

  Future<void> deleteRecord(int recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this maintenance record?',
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
      '/vehicle/${widget.vehicleId}/maintenance-records/$recordId',
      auth: true,
    );

    if (res.statusCode == 200) {
      loadRecords();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete maintenance record')),
    );
  }

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Service History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: loadRecords,
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
            else if (records.isEmpty)
              _emptyState()
            else
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _recordCard(record),
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
            '/add-maintenance',
            arguments: {
              'vehicleId': widget.vehicleId,
              'vehicleTitle': widget.vehicleTitle,
            },
          );

          if (changed == true) {
            loadRecords();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
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
            'View and manage completed maintenance and service records.',
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
          Icon(Icons.receipt_long, size: 48, color: Colors.black45),
          SizedBox(height: 12),
          Text(
            'No maintenance records yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first service record to start building your vehicle history.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _recordCard(Map<String, dynamic> record) {
    final id = record['id'] as int;
    final serviceType = record['service_type']?.toString() ?? 'Unknown Service';
    final serviceDate = record['service_date']?.toString() ?? '--';
    final mileage = record['mileage']?.toString() ?? '--';
    final cost = record['cost'];
    final notes = record['notes']?.toString();

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
                  color: const Color(0xFF5B5CF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  serviceType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => deleteRecord(id),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Record',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              _chip(Icons.event, serviceDate),
              _chip(Icons.speed, '$mileage km'),
              if (cost != null) _chip(Icons.attach_money, cost.toString()),
            ],
          ),
          if (notes != null && notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              notes,
              style: const TextStyle(color: Colors.black54),
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