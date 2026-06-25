import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double totalSales = 0;
  double totalExpenses = 0;
  double totalStockValue = 0;
  List<Map<String, dynamic>> topItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sales = await DatabaseHelper.instance.getSales();
    final expenses = await DatabaseHelper.instance.getExpenses();
    final items = await DatabaseHelper.instance.getItems();

    double sTotal = sales.fold(0, (sum, s) => sum + (s['total'] as double));
    double eTotal =
        expenses.fold(0, (sum, e) => sum + (e['amount'] as double));
    double stockVal = items.fold(
        0,
        (sum, i) =>
            sum + (i['quantity'] as int) * (i['price'] as double));

    setState(() {
      totalSales = sTotal;
      totalExpenses = eTotal;
      totalStockValue = stockVal;
      topItems = items.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double profit = totalSales - totalExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('Reports',
            style: TextStyle(
                color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              _summaryCard('Total Sales',
                  'Rs. ${totalSales.toStringAsFixed(0)}', Colors.green),
              const SizedBox(width: 8),
              _summaryCard('Total Expenses',
                  'Rs. ${totalExpenses.toStringAsFixed(0)}', Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _summaryCard('Net Profit',
                  'Rs. ${profit.toStringAsFixed(0)}',
                  profit >= 0 ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              _summaryCard('Stock Value',
                  'Rs. ${totalStockValue.toStringAsFixed(0)}',
                  const Color(0xFFc9a84c)),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart
          if (totalSales > 0 || totalExpenses > 0)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sales vs Expenses',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                  toY: totalSales,
                                  color: Colors.green,
                                  width: 40)
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                  toY: totalExpenses,
                                  color: Colors.red,
                                  width: 40)
                            ]),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  return Text(
                                      val == 0 ? 'Sales' : 'Expenses',
                                      style: const TextStyle(fontSize: 12));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Top Items
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Inventory Overview',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...topItems.map((item) => ListTile(
                        title: Text(item['name']),
                        subtitle: Text('${item['category']}'),
                        trailing: Text(
                            '${item['quantity']} units\nRs. ${item['price']}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}