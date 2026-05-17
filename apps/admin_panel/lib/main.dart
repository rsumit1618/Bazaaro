import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AdminPanelApp());

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${BazaaroBrand.appName} Admin',
      theme: BazaaroTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Bazaaro Admin',
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.store_outlined),
          label: Text('Sellers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: Text('Orders'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.campaign_outlined),
          label: Text('Marketing'),
        ),
      ],
      child: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: MediaQuery.sizeOf(context).width > 1100 ? 4 : 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: const [
          StatCard(
            label: 'Revenue',
            value: 'INR 12.4L',
            icon: Icons.currency_rupee,
          ),
          StatCard(
            label: 'Orders',
            value: '1,284',
            icon: Icons.shopping_bag_outlined,
          ),
          StatCard(
            label: 'Products',
            value: '8,420',
            icon: Icons.inventory_2_outlined,
          ),
          StatCard(
            label: 'Returns',
            value: '36',
            icon: Icons.assignment_return_outlined,
          ),
        ],
      ),
    );
  }
}
