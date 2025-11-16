import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductListTile extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
    
  const ProductListTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _ProductListTileState createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('Price: \$${widget.product.price} • Stock: ${widget.product.stock}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: widget.onEdit),
            _isDeleting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      setState(() => _isDeleting = true);
                      await widget.onDelete();
                      if (mounted) setState(() => _isDeleting = false);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}