import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> inventoryItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final salesData = await DatabaseHelper.instance.getSales();
    final itemsData = await DatabaseHelper.instance.getItems();
    if (!mounted) return;
    setState(() {
      sales = salesData;
      inventoryItems = itemsData;
    });
  }

  void _showAddSaleDialog() {
    String? selectedItem;
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Item'),
              items: inventoryItems.map((item) => DropdownMenuItem(
                value: item['name'] as String,
                child: Text(item['name']),
              )).toList(),
              onChanged: (val) => selectedItem = val,
            ),
            TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity Sold'), keyboardType: TextInputType.number),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Sale Price (Rs.)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a2744)),
            onPressed: () async {
              if (selectedItem != null) {
                await DatabaseHelper.instance.addSale({
                  'itemName': selectedItem,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'date': DateTime.now().toIso8601String(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = sales.fold(0, (sum, s) => sum + (s['price'] as num).toDouble() * (s['quantity'] as num).toInt());
    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('Sales', style: TextStyle(color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFc9a84c),
        onPressed: _showAddSaleDialog,
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
                const Text('Total Sales', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rs. ${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a2744))),
              ],
            ),
          ),
          Expanded(
            child: sales.isEmpty
                ? const Center(child: Text('No sales added yet', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      final price = (sale['price'] as num).toDouble();
                      final qty = (sale['quantity'] as num).toInt();
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFc9a84c),
                            child: Icon(Icons.shopping_cart, color: Colors.white),
                          ),
                          title: Text(sale['itemName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Qty: $qty'),
                          trailing: Text('Rs. ${(price * qty).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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