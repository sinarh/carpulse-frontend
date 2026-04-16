import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';

class VehicleProfileScreen extends StatefulWidget {
  final int vehicleId;

  const VehicleProfileScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<VehicleProfileScreen> createState() => _VehicleProfileScreenState();
}

class _VehicleProfileScreenState extends State<VehicleProfileScreen> {
  Map<String, dynamic>? vehicle;
  bool loading = true;
  String? error;

  Future<void> loadVehicle() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.get('/vehicle/${widget.vehicleId}', auth: true);

    if (res.statusCode != 200) {
      setState(() {
        loading = false;
        error = 'Failed to load vehicle profile';
      });
      return;
    }

    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() {
        vehicle = data;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'Invalid vehicle profile data';
      });
    }
  }

  Future<void> deleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This will also remove its maintenance records and health snapshots.',
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

    final res = await Api.delete('/vehicle/${widget.vehicleId}', auth: true);

    if (res.statusCode == 200) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/vehicles',
        (route) => false,
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete vehicle')),
    );
  }

  String get vehicleTitle {
    if (vehicle == null) return 'Vehicle';
    final nickname = vehicle!['nickname']?.toString();
    final year = vehicle!['year']?.toString() ?? '';
    final make = vehicle!['make']?.toString() ?? '';
    final model = vehicle!['model']?.toString() ?? '';

    if (nickname != null && nickname.trim().isNotEmpty) {
      return '$nickname • $year $make $model';
    }
    return '$year $make $model'.trim();
  }

  @override
  void initState() {
    super.initState();
    loadVehicle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Vehicle Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () async {
              final changed = await Navigator.pushNamed(
                context,
                '/edit-vehicle',
                arguments: {
                  'vehicleId': widget.vehicleId,
                },
              );

              if (changed == true) {
                loadVehicle();
              }
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Vehicle',
          ),
          IconButton(
            onPressed: deleteVehicle,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Vehicle',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadVehicle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (vehicle != null) ...[
              _profileCard(),
              const SizedBox(height: 16),
              _detailsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0x11000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mileage: ${vehicle!['mileage'] ?? '--'} km',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0x11000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow('Fuel Type', vehicle!['fuel_type']?.toString() ?? '--'),
          _detailRow('Transmission', vehicle!['transmission']?.toString() ?? '--'),
          _detailRow('Purchase Date', vehicle!['purchase_date']?.toString() ?? '--'),
          _detailRow(
            'Notes',
            vehicle!['notes']?.toString().trim().isNotEmpty == true
                ? vehicle!['notes'].toString()
                : '--',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}