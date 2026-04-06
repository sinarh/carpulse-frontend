import "dart:convert";
import "package:flutter/material.dart";
import "../services/api.dart";

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();

  String? error;
  bool loading = false;

  Future<void> save() async {
    final make = makeCtrl.text.trim();
    final model = modelCtrl.text.trim();
    final year = int.tryParse(yearCtrl.text.trim());
    final mileage = int.tryParse(mileageCtrl.text.trim());

    if (make.isEmpty || model.isEmpty || year == null || mileage == null) {
      setState(() => error = "Please fill all fields correctly");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.post(
      "/vehicle/", // your backend uses singular
      {"make": make, "model": model, "year": year, "mileage": mileage},
      auth: true,
    );

    setState(() => loading = false);

    if (res.statusCode != 201 && res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        setState(() => error = data["error"]?.toString() ?? "Failed to add vehicle");
      } catch (_) {
        setState(() => error = "Failed to add vehicle");
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true); // return "refresh = true"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Add Vehicle"),
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
                const Text("Manual Entry", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _field(makeCtrl, "Make", Icons.directions_car_filled_outlined),
                const SizedBox(height: 12),
                _field(modelCtrl, "Model", Icons.badge_outlined),
                const SizedBox(height: 12),
                _field(yearCtrl, "Year", Icons.calendar_month, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _field(mileageCtrl, "Mileage", Icons.speed, keyboardType: TextInputType.number),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(loading ? "Saving..." : "Save Vehicle"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // OBD-II placeholder
          _card(
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bluetooth, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("OBD-II Bluetooth", style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text("Coming soon: auto-detect vehicle data via OBD-II.",
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.lock_outline, color: Colors.black45),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboardType}) {
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
