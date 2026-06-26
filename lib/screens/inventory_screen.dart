import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.instance.getItems();
    setState(() => items = data);
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _loadItems();
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final lowStockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (Rs.)'), keyboardType: TextInputType.number),
              TextField(controller: lowStockController, decoration: const InputDecoration(labelText: 'Low Stock Limit'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a2744)),
            onPressed: () async {
              await DatabaseHelper.instance.addItem({
                'name': nameController.text,
                'category': categoryController.text,
                'quantity': int.tryParse(quantityController.text) ?? 0,
                'price': double.tryParse(priceController.text) ?? 0,
                'lowStockLimit': int.tryParse(lowStockController.text) ?? 5,
              });
              Navigator.pop(context);
              _loadItems();
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a2744),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2744),
        title: const Text('Inventory', style: TextStyle(color: Color(0xFFc9a84c), fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFc9a84c),
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items added yet', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isLowStock = (item['quantity'] as int) <= (item['lowStockLimit'] as int);
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLowStock ? Colors.orange : const Color(0xFF1a2744),
                      child: Text('${item['quantity']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['category']} | Rs. ${item['price']}/unit'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}