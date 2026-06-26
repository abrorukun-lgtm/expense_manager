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
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final salesData = await DatabaseHelper.instance.getSales();
    final expensesData = await DatabaseHelper.instance.getExpenses();

    double sTotal = salesData.fold(0, (sum, s) => sum + (s['price'] as double) * (s['quantity'] as int));
    double eTotal = expensesData.fold(0, (sum, e) => sum + (e['amount'] as double));

    setState(() {
      sales = salesData;
      expenses = expensesData;
      totalSales = sTotal;
      totalExpenses = eTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    double profit = totalSales - totalExpenses;
    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('Reports', style: TextStyle(color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.green, size: 32),
                        const Text('Total Sales', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rs. ${totalSales.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_down, color: Colors.red, size: 32),
                        const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rs. ${totalExpenses.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF1a2744), size: 32),
                  const Text('Net Profit', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rs. ${profit.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: profit >= 0 ? Colors.green : Colors.red)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chart
          if (totalSales > 0 || totalExpenses > 0)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Sales vs Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(toY: totalSales, color: Colors.green, width: 40),
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(toY: totalExpenses, color: Colors.red, width: 40),
                            ]),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  return Text(val == 0 ? 'Sales' : 'Expenses', style: const TextStyle(fontSize: 12));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
        ],
      ),
    );
  }
}