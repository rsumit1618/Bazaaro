import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const StaffApp());

class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${BazaaroBrand.appName} Staff',
      theme: BazaaroTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const StaffDashboardScreen(),
    );
  }
}

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Bazaaro Staff',
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: Text('Inventory'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_shipping_outlined),
          label: Text('Orders'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.support_agent_outlined),
          label: Text('Support'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          StatCard(
            label: 'Inventory alerts',
            value: '17',
            icon: Icons.warning_amber_outlined,
          ),
          SizedBox(height: 12),
          StatCard(
            label: 'Orders to update',
            value: '53',
            icon: Icons.local_shipping_outlined,
          ),
          SizedBox(height: 12),
          StatCard(
            label: 'Support requests',
            value: '12',
            icon: Icons.support_agent_outlined,
          ),
          SizedBox(height: 12),
          StatCard(
            label: 'Marketing tasks',
            value: '6',
            icon: Icons.campaign_outlined,
          ),
        ],
      ),
    );
  }
}
