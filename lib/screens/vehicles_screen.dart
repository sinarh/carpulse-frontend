import "dart:convert";
import "package:flutter/material.dart";
import "../services/api.dart";

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List vehicles = [];
  String? error;

  Future<void> loadVehicles() async {
    setState(() => error = null);

    // NOTE: your backend currently uses /vehicle/ (singular)
    final res = await Api.get("/vehicle/", auth: true);

    if (res.statusCode != 200) {
      setState(() => error = "Failed to load vehicles");
      return;
    }

    setState(() => vehicles = jsonDecode(res.body));
  }

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Vehicles")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: error != null
            ? Text(error!, style: const TextStyle(color: Colors.red))
            : ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (_, i) {
                  final v = vehicles[i];
                  return Card(
                    child: ListTile(
                      title: Text("${v["year"]} ${v["make"]} ${v["model"]}"),
                      subtitle: Text("Mileage: ${v["mileage"]}"),
                      onTap: () {
                        final rawId = v["id"]; // this MUST exist in the JSON
                        final id = (rawId is num) ? rawId.toInt() : null;

                        if (id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vehicle id missing from API response")),
                          );
                          return;
                        }

                        Navigator.pushNamed(
                          context,
                          "/dashboard",
                          arguments: {
                            "vehicleId": id,
                            "vehicleTitle": "${v["year"]} ${v["make"]} ${v["model"]}",
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B5CF6),
        onPressed: () async {
          final changed = await Navigator.pushNamed(context, "/add-vehicle");
          if (changed == true) {
            loadVehicles();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Vehicle"),
      ),

    );
  }
}
