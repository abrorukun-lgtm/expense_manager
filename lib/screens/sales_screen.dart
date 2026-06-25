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
    final s = await DatabaseHelper.instance.getSales();
    final i = await DatabaseHelper.instance.getItems();
    setState(() {
      sales = s;
      inventoryItems = i;
    });
  }

  void _showAddSaleDialog() {
    if (inventoryItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add inventory items first!')),
      );
      return;
    }

    Map<String, dynamic>? selectedItem = inventoryItems.first;
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Sale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedItem,
                decoration: const InputDecoration(labelText: 'Select Item'),
                items: inventoryItems.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text('${item['name']} (${item['quantity']} left)'),
                  );
                }).toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedItem = val),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              if (selectedItem != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Price: Rs. ${selectedItem!['price']}/unit',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFc9a84c)),
              onPressed: () async {
                if (selectedItem == null) return;
                final qty = int.tryParse(quantityController.text) ?? 1;
                final price = selectedItem!['price'] as double;
                final total = qty * price;

                await DatabaseHelper.instance.addSale({
                  'itemId': selectedItem!['id'],
                  'itemName': selectedItem!['name'],
                  'quantity': qty,
                  'price': price,
                  'total': total,
                  'date': DateTime.now().toIso8601String(),
                });

                // Update inventory quantity
                final newQty = (selectedItem!['quantity'] as int) - qty;
                await DatabaseHelper.instance.updateItem({
                  ...selectedItem!,
                  'quantity': newQty < 0 ? 0 : newQty,
                });

                Navigator.pop(context);
                _loadData();
              },
              child: const Text('Add Sale',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalSales = sales.fold(0, (sum, s) => sum + (s['total'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('Sales',
            style: TextStyle(
                color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total Sales: ',
                    style: TextStyle(fontSize: 16)),
                Text('Rs. ${totalSales.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a2744))),
              ],
            ),
          ),
          Expanded(
            child: sales.isEmpty
                ? const Center(
                    child: Text('No sales yet.',
                        style: TextStyle(color: Colors.white54, fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFc9a84c),
                            child: Icon(Icons.shopping_cart,
                                color: Colors.white, size: 18),
                          ),
                          title: Text(sale['itemName'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Qty: ${sale['quantity']} × Rs. ${sale['price']}'),
                          trailing: Text(
                              'Rs. ${sale['total'].toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a2744))),
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