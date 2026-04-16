import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';

class EditVehicleScreen extends StatefulWidget {
  final int vehicleId;

  const EditVehicleScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final nicknameCtrl = TextEditingController();
  final purchaseDateCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? selectedFuelType;
  String? selectedTransmission;

  bool loading = true;
  bool saving = false;
  String? error;

  final fuelTypes = const [
    'Gasoline',
    'Diesel',
    'Hybrid',
    'Electric',
    'Premium',
    'Other',
  ];

  final transmissions = const [
    'Automatic',
    'Manual',
    'CVT',
    'DCT',
    'Other',
  ];

  Future<void> loadVehicle() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.get('/vehicle/${widget.vehicleId}', auth: true);

    if (res.statusCode != 200) {
      setState(() {
        loading = false;
        error = 'Failed to load vehicle details';
      });
      return;
    }

    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      nicknameCtrl.text = data['nickname']?.toString() ?? '';
      makeCtrl.text = data['make']?.toString() ?? '';
      modelCtrl.text = data['model']?.toString() ?? '';
      yearCtrl.text = data['year']?.toString() ?? '';
      mileageCtrl.text = data['mileage']?.toString() ?? '';
      purchaseDateCtrl.text = data['purchase_date']?.toString() ?? '';
      notesCtrl.text = data['notes']?.toString() ?? '';

      selectedFuelType = data['fuel_type']?.toString();
      selectedTransmission = data['transmission']?.toString();

      setState(() {
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'Invalid vehicle data received';
      });
    }
  }

  Future<void> save() async {
    final make = makeCtrl.text.trim();
    final model = modelCtrl.text.trim();
    final year = int.tryParse(yearCtrl.text.trim());
    final mileage = int.tryParse(mileageCtrl.text.trim());
    final nickname = nicknameCtrl.text.trim();
    final purchaseDate = purchaseDateCtrl.text.trim();
    final notes = notesCtrl.text.trim();

    if (make.isEmpty || model.isEmpty || year == null || mileage == null) {
      setState(() => error = 'Make, model, year, and mileage are required');
      return;
    }

    if (purchaseDate.isNotEmpty &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(purchaseDate)) {
      setState(() => error = 'Purchase date must be YYYY-MM-DD');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final payload = <String, dynamic>{
      'make': make,
      'model': model,
      'year': year,
      'mileage': mileage,
      'nickname': nickname.isEmpty ? null : nickname,
      'fuel_type': selectedFuelType,
      'transmission': selectedTransmission,
      'purchase_date': purchaseDate.isEmpty ? null : purchaseDate,
      'notes': notes.isEmpty ? null : notes,
    };

    final res = await Api.put(
      '/vehicle/${widget.vehicleId}',
      payload,
      auth: true,
    );

    setState(() => saving = false);

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        setState(
          () => error = data['error']?.toString() ?? 'Failed to update vehicle',
        );
      } catch (_) {
        setState(() => error = 'Failed to update vehicle');
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    loadVehicle();
  }

  @override
  void dispose() {
    makeCtrl.dispose();
    modelCtrl.dispose();
    yearCtrl.dispose();
    mileageCtrl.dispose();
    nicknameCtrl.dispose();
    purchaseDateCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F4F6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vehicle Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _field(
                  nicknameCtrl,
                  'Nickname (optional)',
                  Icons.drive_file_rename_outline,
                ),
                const SizedBox(height: 12),
                _field(
                  makeCtrl,
                  'Make',
                  Icons.directions_car_filled_outlined,
                ),
                const SizedBox(height: 12),
                _field(modelCtrl, 'Model', Icons.badge_outlined),
                const SizedBox(height: 12),
                _field(
                  yearCtrl,
                  'Year',
                  Icons.calendar_month,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _field(
                  mileageCtrl,
                  'Current Mileage',
                  Icons.speed,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Fuel Type',
                  value: selectedFuelType,
                  items: fuelTypes,
                  icon: Icons.local_gas_station,
                  onChanged: (value) {
                    setState(() => selectedFuelType = value);
                  },
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Transmission',
                  value: selectedTransmission,
                  items: transmissions,
                  icon: Icons.settings,
                  onChanged: (value) {
                    setState(() => selectedTransmission = value);
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  purchaseDateCtrl,
                  'Purchase Date (YYYY-MM-DD)',
                  Icons.event,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
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
                    onPressed: saving ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5CF6),
                      foregroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(saving ? 'Saving...' : 'Save Changes'),
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