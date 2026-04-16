import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_log_screen.dart';
import 'screens/add_maintenance_record_screen.dart';
import 'screens/edit_vehicle_screen.dart';
import 'screens/maintenance_history_screen.dart';
import 'screens/health_snapshot_history_screen.dart';
import 'screens/vehicle_profile_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const CarPulseApp());
}

class CarPulseApp extends StatelessWidget {
  const CarPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/vehicles': (_) => const VehiclesScreen(),
        '/add-vehicle': (_) => const AddVehicleScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/add-log': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;

          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Add Log error: vehicleId missing')),
            );
          }

          return AddLogScreen(vehicleId: id);
        },
        '/add-maintenance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;
          final title = (args?['vehicleTitle'] ?? 'Vehicle').toString();

          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text('Add Maintenance error: vehicleId missing'),
              ),
            );
          }

          return AddMaintenanceRecordScreen(
            vehicleId: id,
            vehicleTitle: title,
          );
        },
        '/edit-vehicle': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;

          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text('Edit Vehicle error: vehicleId missing'),
              ),
            );
          }

          return EditVehicleScreen(vehicleId: id);
        },
        '/maintenance-history': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;
          final title = (args?['vehicleTitle'] ?? 'Vehicle').toString();

          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text('Maintenance History error: vehicleId missing'),
              ),
            );
          }

          return MaintenanceHistoryScreen(
            vehicleId: id,
            vehicleTitle: title,
          );
        },
        '/health-history': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;
          final title = (args?['vehicleTitle'] ?? 'Vehicle').toString();

          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text('Health History error: vehicleId missing'),
              ),
            );
          }

          return HealthSnapshotHistoryScreen(
            vehicleId: id,
            vehicleTitle: title,
          );
        },
        '/vehicle-profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;

          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text('Vehicle Profile error: vehicleId missing'),
              ),
            );
          }

          return VehicleProfileScreen(vehicleId: id);
        },
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final rawId = args?['vehicleId'];
          final id = rawId is num ? rawId.toInt() : null;
          final title = (args?['vehicleTitle'] ?? 'Vehicle').toString();

          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text('Dashboard error: vehicleId missing'),
              ),
            );
          }

          return DashboardScreen(
            vehicleId: id,
            vehicleTitle: title,
          );
        },
      },
    );
  }
}