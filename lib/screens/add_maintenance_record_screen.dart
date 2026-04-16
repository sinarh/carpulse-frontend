import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';

class AddMaintenanceRecordScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleTitle;

  const AddMaintenanceRecordScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleTitle,
  });

  @override
  State<AddMaintenanceRecordScreen> createState() =>
      _AddMaintenanceRecordScreenState();
}

class _AddMaintenanceRecordScreenState
    extends State<AddMaintenanceRecordScreen> {
  final serviceTypeCtrl = TextEditingController();
  final serviceDateCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  bool loading = false;
  String? error;

  final serviceTypes = const [
    'Oil Change',
    'Tire Rotation',
    'Brake Service',
    'Battery Replacement',
    'Air Filter',
    'Spark Plugs',
    'Inspection',
    'Other',
  ];

  String? selectedServiceType;

  Future<void> save() async {
    final serviceType = (selectedServiceType ?? serviceTypeCtrl.text).trim();
    final serviceDate = serviceDateCtrl.text.trim();
    final mileage = int.tryParse(mileageCtrl.text.trim());
    final costText = costCtrl.text.trim();
    final notes = notesCtrl.text.trim();

    if (serviceType.isEmpty || serviceDate.isEmpty || mileage == null) {
      setState(() {
        error = 'Service type, service date, and mileage are required';
      });
      return;
    }

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(serviceDate)) {
      setState(() {
        error = 'Service date must be YYYY-MM-DD';
      });
      return;
    }

    double? cost;
    if (costText.isNotEmpty) {
      cost = double.tryParse(costText);
      if (cost == null) {
        setState(() {
          error = 'Cost must be a number';
        });
        return;
      }
    }

    setState(() {
      loading = true;
      error = null;
    });

    final payload = <String, dynamic>{
      'service_type': serviceType,
      'service_date': serviceDate,
      'mileage': mileage,
    };

    if (cost != null) payload['cost'] = cost;
    if (notes.isNotEmpty) payload['notes'] = notes;

    final res = await Api.post(
      '/vehicle/${widget.vehicleId}/maintenance-records',
      payload,
      auth: true,
    );

    setState(() => loading = false);

    if (res.statusCode != 201 && res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        setState(() {
          error =
              data['error']?.toString() ?? 'Failed to save maintenance record';
        });
      } catch (_) {
        setState(() {
          error = 'Failed to save maintenance record';
        });
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    serviceTypeCtrl.dispose();
    serviceDateCtrl.dispose();
    mileageCtrl.dispose();
    costCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Maintenance Record'),
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
                  widget.vehicleTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track a completed service or repair for this vehicle.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 14),
                _dropdown(
                  label: 'Service Type',
                  value: selectedServiceType,
                  items: serviceTypes,
                  icon: Icons.build,
                  onChanged: (value) {
                    setState(() => selectedServiceType = value);
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  serviceTypeCtrl,
                  'Custom Service Type (optional)',
                  Icons.edit_note,
                ),
                const SizedBox(height: 12),
                _field(
                  serviceDateCtrl,
                  'Service Date (YYYY-MM-DD)',
                  Icons.event,
                ),
                const SizedBox(height: 12),
                _field(
                  mileageCtrl,
                  'Mileage at Service',
                  Icons.speed,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _field(
                  costCtrl,
                  'Cost (optional)',
                  Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF5B5CF6),
                        width: 1.6,
                      ),
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
                      foregroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      loading ? 'Saving...' : 'Save Maintenance Record',
                    ),
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