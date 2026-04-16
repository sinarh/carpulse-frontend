import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Vehicle> vehicles = [];
  String? error;
  bool loading = true;

  Future<void> loadVehicles() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.get('/vehicle/', auth: true);

    if (res.statusCode != 200) {
      setState(() {
        loading = false;
        error = 'Failed to load vehicles';
      });
      return;
    }

    try {
      final data = jsonDecode(res.body) as List;
      setState(() {
        vehicles = data
            .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
            .toList();
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'Invalid vehicle data received';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('My Vehicles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                  )
                : vehicles.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: loadVehicles,
                        child: ListView.separated(
                          itemCount: vehicles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final v = vehicles[i];
                            return _vehicleCard(v);
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B5CF6),
        foregroundColor: const Color(0xFFE5E7EB),
        onPressed: () async {
          final changed = await Navigator.pushNamed(context, '/add-vehicle');
          if (changed == true) {
            loadVehicles();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 48, color: Colors.black45),
            SizedBox(height: 12),
            Text(
              'No vehicles yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Add your first vehicle to start tracking maintenance and health data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/dashboard',
          arguments: {
            'vehicleId': v.id,
            'vehicleTitle': v.displayTitle,
          },
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF5B5CF6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.directions_car, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.displayTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mileage: ${v.mileage} km',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (v.fuelType != null || v.transmission != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (v.fuelType != null) v.fuelType,
                        if (v.transmission != null) v.transmission,
                      ].join(' • '),
                      style: const TextStyle(color: Colors.black45),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}