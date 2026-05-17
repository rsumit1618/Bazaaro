import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_ui/bazaaro_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SellerPanelApp());

class SellerPanelApp extends StatelessWidget {
  const SellerPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${BazaaroBrand.appName} Seller',
      theme: BazaaroTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const SellerDashboardScreen(),
    );
  }
}

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Bazaaro Seller',
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_box_outlined),
          label: Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.warehouse_outlined),
          label: Text('Stock'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: Text('Orders'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: Text('Earnings'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 260,
                child: StatCard(
                  label: 'Earnings',
                  value: 'INR 2.6L',
                  icon: Icons.currency_rupee,
                ),
              ),
              SizedBox(
                width: 260,
                child: StatCard(
                  label: 'Live products',
                  value: '142',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              SizedBox(
                width: 260,
                child: StatCard(
                  label: 'Pending orders',
                  value: '28',
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
