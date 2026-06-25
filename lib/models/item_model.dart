class Item {
  int? id;
  String name;
  String category;
  int quantity;
  double price;
  int lowStockLimit;

  Item({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.lowStockLimit = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'lowStockLimit': lowStockLimit,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      price: map['price'],
      lowStockLimit: map['lowStockLimit'] ?? 5,
    );
  }
}