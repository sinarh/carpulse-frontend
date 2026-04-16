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
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _carHealthCard(),
              const SizedBox(height: 16),
              _snapshotSummaryCard(context),
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
          ],
        ),
      ),
    );
  }

  Widget _carHealthCard() {
    final hasSnapshot = latestSnapshot != null;

    String title;
    String msg;
    Color statusColor;
    IconData statusIcon;

    if (!hasSnapshot) {
      title = 'No Data Yet';
      msg = 'Add a health snapshot to start tracking this vehicle.';
      statusColor = const Color(0xFF6B7280);
      statusIcon = Icons.info_outline;
    } else if (latestSnapshot?['check_engine_light'] == true) {
      title = 'Attention Needed';
      msg = 'Check engine light is marked on.';
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.warning_amber_rounded;
    } else if ((latestSnapshot?['battery_status'] == 'Needs Service') ||
        (latestSnapshot?['tire_status'] == 'Needs Service') ||
        (latestSnapshot?['brake_status'] == 'Needs Service')) {
      title = 'Service Recommended';
      msg = 'One or more systems may need service soon.';
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.build_circle_outlined;
    } else {
      title = 'Healthy';
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
            width: 48,
            height: 48,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
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

  Widget _snapshotSummaryCard(BuildContext context) {
    final mileage = latestSnapshot?['mileage']?.toString() ?? '--';
    final cel = latestSnapshot?['check_engine_light'] == true ? 'On' : 'Off';
    final battery = latestSnapshot?['battery_status']?.toString() ?? 'Unknown';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Latest Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
          const SizedBox(height: 8),
          Text(
            latestSnapshot == null
                ? 'No health snapshot has been added yet.'
                : 'Mileage: $mileage km • Check Engine: $cel • Battery: $battery',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _moduleGrid(BuildContext context) {
    final items = <_ModuleItem>[
      _ModuleItem(
        Icons.person_outline,
        'Vehicle Profile',
        'View fuel type, notes, and purchase info',
      ),
      _ModuleItem(
        Icons.calendar_month,
        'Maintenance Schedule',
        'Add a completed maintenance record',
      ),
      _ModuleItem(
        Icons.receipt_long,
        'Service History',
        'View all maintenance records',
      ),
      _ModuleItem(
        Icons.health_and_safety,
        'Health History',
        'View all health snapshots',
      ),
      _ModuleItem(
        Icons.build,
        'Add Health Snapshot',
        'Record a new vehicle health check',
      ),
      _ModuleItem(
        Icons.trending_up,
        'Performance Stats',
        'Coming soon',
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
            if (m.title == 'Vehicle Profile') {
              await Navigator.pushNamed(
                context,
                '/vehicle-profile',
                arguments: {
                  'vehicleId': widget.vehicleId,
                },
              );
              return;
            }

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

            if (m.title == 'Health History') {
              await Navigator.pushNamed(
                context,
                '/health-history',
                arguments: {
                  'vehicleId': widget.vehicleId,
                  'vehicleTitle': widget.vehicleTitle,
                },
              );
              return;
            }

            if (m.title == 'Add Health Snapshot') {
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