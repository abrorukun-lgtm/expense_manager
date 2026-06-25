class Sale {
  int? id;
  int itemId;
  String itemName;
  int quantity;
  double price;
  double total;
  String date;

  Sale({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'total': total,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      itemId: map['itemId'],
      itemName: map['itemName'],
      quantity: map['quantity'],
      price: map['price'],
      total: map['total'],
      date: map['date'],
    );
  }
}