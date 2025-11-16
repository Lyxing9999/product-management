import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/notification.dart';
import 'package:flutter/services.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  const ProductForm({super.key, this.product});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final ProductService productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final product = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
    );

    try {
      if (widget.product == null) {
        await productService.createProduct(product);
        if (mounted) showMessage(context, 'Product created successfully', type: MessageType.success);
      } else {
        await productService.updateProduct(product.id.toString(), product);
        if (mounted) showMessage(context, 'Product updated successfully', type: MessageType.success);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showMessage(context, 'Error: $e', type: MessageType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateNumber(String? value, {bool isDouble = false}) {
    if (value == null || value.isEmpty) return 'This field is required';
    final val = value.trim();
    if (isDouble) {
      if (double.tryParse(val) == null) return 'Enter a valid number';
    } else {
      if (int.tryParse(val) == null) return 'Enter a valid integer';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Enter name' : null,
                  readOnly: _isLoading,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  validator: (value) => _validateNumber(value, isDouble: true),
                  readOnly: _isLoading,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateNumber(value, isDouble: false),
                  readOnly: _isLoading,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}