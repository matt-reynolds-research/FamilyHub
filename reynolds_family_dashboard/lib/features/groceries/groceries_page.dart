import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/grocery_item.dart';

class GroceriesPage extends ConsumerWidget {
  const GroceriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groceries = ref.watch(mockGroceriesProvider);
    
    // Group by category
    final Map<String, List<GroceryItem>> grouped = {};
    for (var item in groceries) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Groceries', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(width: 32),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add an item...',
                    prefixIcon: const Icon(Icons.add_shopping_cart),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final category = grouped.keys.elementAt(index);
                final items = grouped[category]!;
                return _buildCategoryCard(context, category, items);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, List<GroceryItem> items) {
    return Container(
      width: 350,
      margin: const EdgeInsets.only(right: 24),
      child: Card(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.accentPurple, width: 4)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(category, style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: const Icon(Icons.radio_button_unchecked, color: AppColors.primaryIndigo),
                    title: Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${item.quantity}', style: const TextStyle(color: AppColors.primaryIndigo, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
