import 'package:flutter/material.dart';

class ProductFilters extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final TextEditingController minStockController;
  final TextEditingController maxStockController;

  final void Function() onChanged;
  final String? sortBy;       
  final String? sortDirection; 
  final void Function(String?, String?) onSortChanged;
  final void Function() onClear;

  final bool isFiltering; 

  const ProductFilters({
    super.key,
    required this.minPriceController,
    required this.maxPriceController,
    required this.minStockController,
    required this.maxStockController,
    required this.onChanged,
    required this.sortBy,
    required this.sortDirection,
    required this.onSortChanged,
    required this.onClear,
    this.isFiltering = false, 
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          const Text('Filters & Sorting'),
          if (isFiltering) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ]
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // PRICE FILTERS
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Min Price',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: maxPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Max Price',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),


              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minStockController,
                      decoration: const InputDecoration(labelText: 'Min Stock'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: maxStockController,
                      decoration: const InputDecoration(labelText: 'Max Stock'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),


              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: sortBy,
                      decoration: const InputDecoration(labelText: 'Sort By'),
                      items: const [
                        DropdownMenuItem(value: 'PRICE', child: Text('Price')),
                        DropdownMenuItem(value: 'STOCK', child: Text('Stock')),
                      ],
                      onChanged: (val) => onSortChanged(val, sortDirection),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: sortDirection,
                      decoration: const InputDecoration(labelText: 'Order'),
                      items: const [
                        DropdownMenuItem(value: 'ASC', child: Text('Low → High')),
                        DropdownMenuItem(value: 'DESC', child: Text('High → Low')),
                      ],
                      onChanged: (val) => onSortChanged(sortBy, val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onClear,
                  child: const Text("Clear Filters"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}