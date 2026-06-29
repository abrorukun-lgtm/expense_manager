import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import 'inventory_screen.dart';
import 'expenses_screen.dart' as exp;
import 'sales_screen.dart' as sal;
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardHome(),
    InventoryScreen(),
    sal.SalesScreen(),
    exp.ExpensesScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1a2744),
        selectedItemColor: const Color(0xFFc9a84c),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Sales'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int totalUnits = 0;
  double totalValue = 0;
  List<Map<String, dynamic>> lowStockItems = [];
  List<Map<String, dynamic>> inventoryItems = [];
  Map<String, double> categoryData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final items = await DatabaseHelper.instance.getItems();
      if (!mounted) return;
      int units = 0;
      double value = 0;
      Map<String, double> catData = {};
      List<Map<String, dynamic>> lowStock = [];

      for (var item in items) {
        final qty = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toDouble();
        final limit = (item['lowStockLimit'] as num).toInt();
        units += qty;
        value += qty * price;
        final cat = item['category']?.toString() ?? 'Other';
        catData[cat] = (catData[cat] ?? 0) + qty;
        if (qty <= limit) lowStock.add(item);
      }

      setState(() {
        totalUnits = units;
        totalValue = value;
        categoryData = catData;
        lowStockItems = lowStock;
        inventoryItems = items;
      });
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('MY BUSINESS: INVENTORY',
            style: TextStyle(color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Current Stock Status',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$totalUnits',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1a2744))),
                    const Text('Total units'),
                    const SizedBox(height: 8),
                    Text('Rs. ${totalValue.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2744))),
                    const Text('Total Stock Value'),
                    const SizedBox(height: 16),
                    if (categoryData.isNotEmpty)
                      SizedBox(
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            sections: categoryData.entries.map((e) {
                              final colors = [
                                const Color(0xFF1a2744),
                                const Color(0xFFc9a84c),
                                Colors.green,
                                Colors.red
                              ];
                              final idx = categoryData.keys.toList().indexOf(e.key);
                              return PieChartSectionData(
                                value: e.value,
                                title: e.key,
                                color: colors[idx % colors.length],
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (lowStockItems.isNotEmpty)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Low Stock Alerts',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      ...lowStockItems.map((item) => ListTile(
                            leading: const Icon(Icons.warning_amber, color: Colors.orange),
                            title: Text('${item['name']} (${item['quantity']} units left)'),
                          )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ...inventoryItems.map((item) => ListTile(
                          title: Text(item['name']),
                          subtitle: Text('${item['quantity']} Units - Rs. ${item['price']}/u'),
                        )),
                    if (inventoryItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No inventory items yet'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}