import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/ai_assistant_card.dart';

class DashboardScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleTitle;

  const DashboardScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleTitle,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? latestSnapshot;
  String? error;
  bool loading = true;

  Future<void> loadLatestSnapshot() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.get(
      '/vehicle/${widget.vehicleId}/health-snapshots',
      auth: true,
    );

    if (res.statusCode != 200) {
      setState(() {
        loading = false;
        error = 'Failed to load vehicle health data';
      });
      return;
    }

    try {
      final data = jsonDecode(res.body);
      Map<String, dynamic>? latest;

      if (data is List && data.isNotEmpty) {
        latest = Map<String, dynamic>.from(data.first);
      }

      setState(() {
        latestSnapshot = latest;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'Invalid dashboard data received';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadLatestSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12, right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.directions_car, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CarPulse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.vehicleTitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
              tooltip: 'Notifications',
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadLatestSnapshot,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _carHealthCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Latest Health Snapshot',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final changed = await Navigator.pushNamed(
                      context,
                      '/add-log',
                      arguments: {
                        'vehicleId': widget.vehicleId,
                        'vehicleTitle': widget.vehicleTitle,
                      },
                    );
                    if (changed == true) {
                      loadLatestSnapshot();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Snapshot'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _liveDataGrid(),
            const SizedBox(height: 20),
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _moduleGrid(context),
            const SizedBox(height: 20),
            AIAssistantCard(vehicleId: widget.vehicleId),
          ],
        ),
      ),
    );
  }

  Widget _carHealthCard() {
    final hasSnapshot = latestSnapshot != null;

    String msg;
    Color statusColor;
    IconData statusIcon;

    if (!hasSnapshot) {
      msg = 'No health snapshot yet. Add one to see vehicle condition.';
      statusColor = const Color(0xFF6B7280);
      statusIcon = Icons.info_outline;
    } else if (latestSnapshot?['check_engine_light'] == true) {
      msg = 'Check engine light is marked on. Vehicle may need attention.';
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.warning_amber_rounded;
    } else if ((latestSnapshot?['battery_status'] == 'Needs Service') ||
        (latestSnapshot?['tire_status'] == 'Needs Service') ||
        (latestSnapshot?['brake_status'] == 'Needs Service')) {
      msg = 'One or more systems may need service soon.';
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.build_circle_outlined;
    } else {
      msg = 'Latest manual health snapshot looks stable.';
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x11000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Car Health',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(msg, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveDataGrid() {
    final fuel = latestSnapshot?['fuel_level'];
    final temp = latestSnapshot?['engine_temp'];
    final mileage = latestSnapshot?['mileage'];
    final battery = latestSnapshot?['battery_status'];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _liveTile(
          icon: Icons.local_gas_station,
          label: 'Fuel Level',
          value: fuel?.toString() ?? '--',
          unit: fuel != null ? '%' : '',
        ),
        _liveTile(
          icon: Icons.thermostat,
          label: 'Engine Temp',
          value: temp?.toString() ?? '--',
          unit: temp != null ? '°C' : '',
        ),
        _liveTile(
          icon: Icons.speed,
          label: 'Mileage',
          value: mileage?.toString() ?? '--',
          unit: mileage != null ? 'km' : '',
        ),
        _liveTile(
          icon: Icons.battery_full,
          label: 'Battery',
          value: battery?.toString() ?? '--',
          unit: '',
        ),
      ],
    );
  }

  Widget _liveTile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x11000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(color: Colors.black54)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _moduleGrid(BuildContext context) {
    final items = <_ModuleItem>[
      _ModuleItem(
        Icons.calendar_month,
        'Maintenance Schedule',
        'Upcoming and overdue tasks',
      ),
      _ModuleItem(
        Icons.receipt_long,
        'Service History',
        'Record of services and repairs',
      ),
      _ModuleItem(
        Icons.build,
        'Diagnostic Tools',
        'Codes and system checks',
      ),
      _ModuleItem(
        Icons.warning_amber,
        'Active Alerts',
        'Current vehicle alerts',
      ),
      _ModuleItem(
        Icons.trending_up,
        'Performance Stats',
        'Fuel economy + patterns',
      ),
      _ModuleItem(
        Icons.map_outlined,
        'Trip History',
        'Past trips and locations',
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 92,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final m = items[i];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (m.title == 'Service History') {
            await Navigator.pushNamed(
              context,
              '/maintenance-history',
              arguments: {
                'vehicleId': widget.vehicleId,
                'vehicleTitle': widget.vehicleTitle,
              },
            );
            return;
          }
          if (m.title == 'Maintenance Schedule') {
            final changed = await Navigator.pushNamed(
              context,
              '/add-maintenance',
              arguments: {
                'vehicleId': widget.vehicleId,
                'vehicleTitle': widget.vehicleTitle,
              },
            );
            if (changed == true) {
              loadLatestSnapshot();
            }
            return;
          }

            if (m.title == 'Diagnostic Tools' ||
                m.title == 'Active Alerts') {
              final changed = await Navigator.pushNamed(
                context,
                '/add-log',
                arguments: {
                  'vehicleId': widget.vehicleId,
                  'vehicleTitle': widget.vehicleTitle,
                },
              );
              if (changed == true) {
                loadLatestSnapshot();
              }
              return;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Color(0x11000000),
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(m.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        m.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.desc,
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black45),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModuleItem {
  final IconData icon;
  final String title;
  final String desc;

  _ModuleItem(this.icon, this.title, this.desc);
}