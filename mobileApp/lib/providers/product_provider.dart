import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/notification.dart';
import '../utils/dialog.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  // --- Data ---
  List<Product> _products = [];
  List<Product> get products => _products;

  // --- Loading states ---
  bool _isLoadingList = false; 
  bool get isLoadingList => _isLoadingList;

  bool _isFiltering = false; 
  bool get isFiltering => _isFiltering;

  // --- Pagination ---
  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  // --- Error ---
  String? _error;
  String? get error => _error;

  // --- Setters ---
  void setLoadingList(bool value) {
    _isLoadingList = value;
    notifyListeners();
  }

  void setFiltering(bool value) {
    _isFiltering = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }


  bool _isExporting = false;
  bool get isExporting => _isExporting;
  void setExporting(bool value) {
    _isExporting = value;
    notifyListeners();
  }

  // --- Fetch/Search Products ---
Future<void> searchProducts({
  String? name,
  double? minPrice,
  double? maxPrice,
  int? minStock,
  int? maxStock,
  int page = 1,
  int limit = 10,
  String? sortBy,
  String? sortDirection,
  bool loadMore = false,
  bool useMainLoader = true, // NEW
}) async {
  if (!loadMore) {
    _currentPage = 1;
    _hasMore = true;
    _products = [];
  } else {
    _currentPage++;
  }

  if (!_hasMore) return;

  if (useMainLoader) setLoadingList(true);
  setError(null);

  try {
    final response = await _service.searchProducts(
      name: name,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minStock: minStock,
      maxStock: maxStock,
      page: _currentPage,
      limit: limit,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );

    if (response.success && response.data != null) {
      final data = response.data;
      final List<Product> fetchedProducts =
          (data?['products'] as List?)
                  ?.map((p) => Product.fromJson(p as Map<String, dynamic>))
                  .toList() ??
              [];

      if (loadMore) {
        _products.addAll(fetchedProducts);
      } else {
        _products = fetchedProducts;
      }

      final totalPages = int.tryParse(data?['totalPages']?.toString() ?? '1') ?? 1;
      _hasMore = _currentPage < totalPages;
    } else {
      setError(response.message ?? "Failed to fetch products");
    }
  } catch (e) {
    setError(e.toString());
  }

  if (useMainLoader) setLoadingList(false);
}
  // --- Add Product ---
  Future<void> addProduct(Product product) async {
    setLoadingList(true);
    setError(null);

    try {
      final response = await _service.createProduct(product);
      if (response.success && response.data != null) {
        _products.add(Product.fromJson(response.data!));
      } else {
        setError(response.message ?? "Failed to add product");
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoadingList(false);
    }
  }

  // --- Update Product ---
  Future<void> updateProduct(Product product) async {
    setLoadingList(true);
    setError(null);

    try {
      final response = await _service.updateProduct(product.id.toString(), product);
      if (response.success && response.data != null) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = Product.fromJson(response.data!);
        }
      } else {
        setError(response.message ?? "Failed to update product");
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoadingList(false);
    }
  }

  // --- Delete Product ---
  Future<void> deleteProduct(BuildContext context, int id) async {
    final confirm = await showDeleteConfirmation(context);
    if (confirm != true) return;

    setLoadingList(true);
    setError(null);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await _service.deleteProduct(id);
      Navigator.pop(context);

      if (response.success) {
        _products.removeWhere((p) => p.id == id);
        showMessage(context, 'Product deleted successfully', type: MessageType.success);
      } else {
        showMessage(context, response.message ?? 'Failed to delete product', type: MessageType.error);
      }
    } catch (e) {
      Navigator.pop(context);
      showMessage(context, 'Error: $e', type: MessageType.error);
    } finally {
      setLoadingList(false);
    }
  }

  // --- Export CSV ---
  Future<void> exportCSV(BuildContext context, {Map<String, String>? filters}) async {
    setExporting(true);
    setError(null);

    try {
      await _service.exportCSV(filters: filters);
      showMessage(context, 'CSV exported successfully', type: MessageType.success);
    } catch (e) {
      debugPrint('Export CSV error: $e');
      setError(e.toString());
    } finally {
      setExporting(false);
    }
  }

  // --- Export PDF ---
  Future<void> exportPDF(BuildContext context, {Map<String, String>? filters}) async {
    setExporting(true);
    setError(null);

    try {
      await _service.exportPDF(filters: filters);
      showMessage(context, 'PDF exported successfully', type: MessageType.success);
    } catch (e) {
      debugPrint('Export PDF error: $e');
      setError(e.toString());
    } finally {
      setExporting(false);
    }
  }
}