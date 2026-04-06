import "dart:convert";
import "package:flutter/material.dart";
import "../services/api.dart";

class AddLogScreen extends StatefulWidget {
  final int vehicleId;
  const AddLogScreen({super.key, required this.vehicleId});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final mileageCtrl = TextEditingController();
  final fuelCtrl = TextEditingController();
  final tempCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? error;
  bool loading = false;

  Future<void> save() async {
    final mileage = int.tryParse(mileageCtrl.text.trim());
    final fuel = int.tryParse(fuelCtrl.text.trim());
    final temp = double.tryParse(tempCtrl.text.trim());
    final notes = notesCtrl.text.trim();

    // Allow partial, but at least ONE field should be provided
    if (mileage == null && fuel == null && temp == null && notes.isEmpty) {
      setState(() => error = "Enter at least one value");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final payload = <String, dynamic>{};
    if (mileage != null) payload["mileage"] = mileage;
    if (fuel != null) payload["fuel_level"] = fuel;
    if (temp != null) payload["engine_temp"] = temp;
    if (notes.isNotEmpty) payload["notes"] = notes;

    final res = await Api.post(
      "/vehicle/${widget.vehicleId}/logs",
      payload,
      auth: true,
    );

    print("ADD LOG status: ${res.statusCode}");
    print("ADD LOG body: ${res.body}");

    setState(() => loading = false);

    if (res.statusCode != 201 && res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        setState(() => error = data["error"]?.toString() ?? "Failed to add log");
      } catch (_) {
        setState(() => error = "Failed to add log");
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true); // tell dashboard to refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Add Vehicle Log"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              children: [
                _field(mileageCtrl, "Mileage", Icons.speed, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _field(fuelCtrl, "Fuel Level (0-100)", Icons.local_gas_station, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _field(tempCtrl, "Engine Temp (°C)", Icons.thermostat, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Notes (optional)",
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
                ),
                const SizedBox(height: 12),
                if (error != null) ...[
                  Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5CF6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(loading ? "Saving..." : "Save Log"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType}) {
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0x11000000), offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}
