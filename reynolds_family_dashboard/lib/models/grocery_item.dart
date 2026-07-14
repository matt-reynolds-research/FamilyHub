class GroceryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool isChecked;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isChecked = false,
  });
}
