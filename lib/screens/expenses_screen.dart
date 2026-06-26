import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await DatabaseHelper.instance.getExpenses();
    setState(() => expenses = data);
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadExpenses();
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount (Rs.)'), keyboardType: TextInputType.number),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a2744)),
            onPressed: () async {
              await DatabaseHelper.instance.addExpense({
                'title': titleController.text,
                'amount': double.tryParse(amountController.text) ?? 0,
                'category': categoryController.text,
                'date': DateTime.now().toIso8601String(),
              });
              Navigator.pop(context);
              _loadExpenses();
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = expenses.fold(0, (sum, e) => sum + (e['amount'] as double));
    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('Expenses', style: TextStyle(color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFc9a84c),
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rs. ${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a2744))),
              ],
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses added yet', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1a2744),
                            child: Icon(Icons.receipt, color: Colors.white),
                          ),
                          title: Text(expense['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(expense['category'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rs. ${expense['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(expense['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}