class GroceryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool isChecked;
  final String? addedBy;

  GroceryItem({
    required this.id,
    required this.name,
    this.category = 'Other',
    this.quantity = 1,
    this.isChecked = false,
    this.addedBy,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    // Supabase schema uses 'quantity' as TEXT; parse to int
    final rawQty = json['quantity'];
    int qty = 1;
    if (rawQty is int) {
      qty = rawQty;
    } else if (rawQty is String) {
      qty = int.tryParse(rawQty) ?? 1;
    }

    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: 'Other', // No category column in DB — default
      quantity: qty,
      isChecked: json['is_purchased'] as bool? ?? false,
      addedBy: json['added_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity.toString(),
      'is_purchased': isChecked,
      'added_by': addedBy,
    };
  }

  GroceryItem copyWith({bool? isChecked}) {
    return GroceryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      isChecked: isChecked ?? this.isChecked,
      addedBy: addedBy,
    );
  }
}
