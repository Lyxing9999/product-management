import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final String query;
  final void Function(String) onChanged;

  const ProductSearchBar({super.key, required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search by name',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}