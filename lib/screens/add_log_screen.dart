import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';

class AddLogScreen extends StatefulWidget {
  final int vehicleId;

  const AddLogScreen({super.key, required this.vehicleId});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final mileageCtrl = TextEditingController();
  final fuelLevelCtrl = TextEditingController();
  final engineTempCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? batteryStatus;
  String? tireStatus;
  String? brakeStatus;
  bool checkEngineLight = false;
  bool loading = false;
  String? error;

  final statusOptions = const ['Good', 'Watch Soon', 'Needs Service'];

  Future<void> save() async {
    final mileage = int.tryParse(mileageCtrl.text.trim());
    final fuelLevel = fuelLevelCtrl.text.trim();
    final engineTemp = engineTempCtrl.text.trim();
    final notes = notesCtrl.text.trim();

    if (mileage == null) {
      setState(() => error = 'Mileage is required');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final payload = <String, dynamic>{
      'mileage': mileage,
      'check_engine_light': checkEngineLight,
    };

    if (fuelLevel.isNotEmpty) {
      final parsedFuel = double.tryParse(fuelLevel);
      if (parsedFuel == null) {
        setState(() {
          loading = false;
          error = 'Fuel level must be a number';
        });
        return;
      }
      payload['fuel_level'] = parsedFuel;
    }

    if (engineTemp.isNotEmpty) {
      final parsedTemp = double.tryParse(engineTemp);
      if (parsedTemp == null) {
        setState(() {
          loading = false;
          error = 'Engine temp must be a number';
        });
        return;
      }
      payload['engine_temp'] = parsedTemp;
    }

    if (batteryStatus != null) payload['battery_status'] = batteryStatus;
    if (tireStatus != null) payload['tire_status'] = tireStatus;
    if (brakeStatus != null) payload['brake_status'] = brakeStatus;
    if (notes.isNotEmpty) payload['notes'] = notes;

    final res = await Api.post(
      '/vehicle/${widget.vehicleId}/health-snapshots',
      payload,
      auth: true,
    );

    setState(() => loading = false);

    if (res.statusCode != 201 && res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        setState(
          () => error =
              data['error']?.toString() ?? 'Failed to save health snapshot',
        );
      } catch (_) {
        setState(() => error = 'Failed to save health snapshot');
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    mileageCtrl.dispose();
    fuelLevelCtrl.dispose();
    engineTempCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final vehicleTitle = args?['vehicleTitle'] as String? ?? 'Vehicle';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Health Snapshot'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Capture a quick manual health check for this vehicle.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 14),
                _field(
                  mileageCtrl,
                  'Current Mileage',
                  Icons.speed,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _field(
                  fuelLevelCtrl,
                  'Fuel Level % (optional)',
                  Icons.local_gas_station,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                _field(
                  engineTempCtrl,
                  'Engine Temp °C (optional)',
                  Icons.thermostat,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: checkEngineLight,
                  onChanged: (value) => setState(() => checkEngineLight = value),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Check Engine Light'),
                ),
                const SizedBox(height: 4),
                _dropdown(
                  label: 'Battery Status',
                  value: batteryStatus,
                  items: statusOptions,
                  icon: Icons.battery_charging_full,
                  onChanged: (value) => setState(() => batteryStatus = value),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Tire Status',
                  value: tireStatus,
                  items: statusOptions,
                  icon: Icons.tire_repair,
                  onChanged: (value) => setState(() => tireStatus = value),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Brake Status',
                  value: brakeStatus,
                  items: statusOptions,
                  icon: Icons.car_repair,
                  onChanged: (value) => setState(() => brakeStatus = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: const Icon(Icons.notes),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF5B5CF6), width: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (error != null) ...[
                  Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(loading ? 'Saving...' : 'Save Snapshot'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5B5CF6), width: 1.6),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5B5CF6), width: 1.6),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
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
      child: child,
    );
  }
}