import "package:carpulse_mobile/screens/dashboard_screen.dart";
import "package:flutter/material.dart";
import "screens/login_screen.dart";
import "screens/vehicles_screen.dart";
import "screens/register_screen.dart";
import "screens/add_vehicle_screen.dart";
import "screens/add_log_screen.dart";
import "screens/settings_screen.dart";



void main() {
  runApp(const CarPulseApp());
}

class CarPulseApp extends StatelessWidget {
  const CarPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CarPulse",
      routes: {
        "/": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),
        "/vehicles": (_) => const VehiclesScreen(),
        "/add-vehicle": (_) => const AddVehicleScreen(),
        "/dashboard": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final rawId = args?["vehicleId"];
          final id = (rawId is num) ? rawId.toInt() : null;

          if (id == null) {
            return const Scaffold(
              body: Center(child: Text("Dashboard error: vehicleId missing")),
            );
          }

          return DashboardScreen(
            vehicleId: id,
            vehicleTitle: (args?["vehicleTitle"] ?? "Vehicle") as String,
          );
        },
        "/add-log": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final rawId = args?["vehicleId"];
          final id = (rawId is num) ? rawId.toInt() : null;

          if (id == null) {
            return const Scaffold(body: Center(child: Text("Add Log error: vehicleId missing")));
          }

          return AddLogScreen(vehicleId: id);
        },
        "/settings": (_) => const SettingsScreen(),

      },
    );
  }
}
