import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product/product_filters.dart';
import '../widgets/product/product_list_tile.dart';
import '../widgets/product/product_search_bar.dart';
import 'product_form.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  Timer? _debounce;
  final _scrollController = ScrollController();

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();

  String _sortBy = 'PRICE';
  String _sortDirection = 'ASC';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInitialProducts());
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchInitialProducts() async {
    final provider = context.read<ProductProvider>();
    provider.setFiltering(true);
    await provider.searchProducts(
      page: 1,
      limit: 10,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );
    provider.setFiltering(false);
  }

  void _onFilterChanged(String? searchQuery) {
    final provider = context.read<ProductProvider>();
    provider.setFiltering(true);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await provider.searchProducts(
        name: searchQuery,
        minPrice: _minPriceController.text.isNotEmpty
            ? double.tryParse(_minPriceController.text)
            : null,
        maxPrice: _maxPriceController.text.isNotEmpty
            ? double.tryParse(_maxPriceController.text)
            : null,
        minStock: _minStockController.text.isNotEmpty
            ? int.tryParse(_minStockController.text)
            : null,
        maxStock: _maxStockController.text.isNotEmpty
            ? int.tryParse(_maxStockController.text)
            : null,
        page: 1,
        limit: 10,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
        loadMore: false,
      );
      provider.setFiltering(false);
    });
  }

  void _onSortChanged(String? sortBy, String? sortDirection) {
    setState(() {
      if (sortBy != null) _sortBy = sortBy;
      if (sortDirection != null) _sortDirection = sortDirection;
    });
    _onFilterChanged(null);
  }

  void _onScroll() {
    final provider = context.read<ProductProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !provider.isLoadingList &&
        provider.hasMore) {
      provider.searchProducts(
        page: provider.currentPage + 1,
        limit: 10,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
        loadMore: true,
      );
    }
  }

  void _openForm([product]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductForm(product: product)),
    );
    if (result == true) _fetchInitialProducts();
  }

  Map<String, String> getCurrentFilters() {
    return {
      if (_minPriceController.text.isNotEmpty) 'minPrice': _minPriceController.text,
      if (_maxPriceController.text.isNotEmpty) 'maxPrice': _maxPriceController.text,
      if (_minStockController.text.isNotEmpty) 'minStock': _minStockController.text,
      if (_maxStockController.text.isNotEmpty) 'maxStock': _maxStockController.text,
      'sortBy': _sortBy,
      'sortDirection': _sortDirection,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          // Search bar
          ProductSearchBar(query: '', onChanged: _onFilterChanged),

          // Filters
          ProductFilters(
            minPriceController: _minPriceController,
            maxPriceController: _maxPriceController,
            minStockController: _minStockController,
            maxStockController: _maxStockController,
            sortBy: _sortBy,
            sortDirection: _sortDirection,
            onSortChanged: _onSortChanged,
            onChanged: () => _onFilterChanged(null),
            onClear: () {
              _minPriceController.clear();
              _maxPriceController.clear();
              _minStockController.clear();
              _maxStockController.clear();
              setState(() {
                _sortBy = 'PRICE';
                _sortDirection = 'ASC';
              });
              _onFilterChanged(null);
            },
            isFiltering: provider.isFiltering,
          ),

          // Export buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: provider.isExporting
                      ? null
                      : () => provider.exportCSV(context, filters: getCurrentFilters()),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export CSV'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: provider.isExporting
                      ? null
                      : () => provider.exportPDF(context, filters: getCurrentFilters()),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                ),
                if (provider.isExporting)
                  const SizedBox(width: 16),
                if (provider.isExporting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

  
          Expanded(
            child: provider.isFiltering || (provider.isLoadingList && provider.products.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : provider.products.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : RefreshIndicator(
                        onRefresh: _fetchInitialProducts,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index < provider.products.length) {
                              final product = provider.products[index];
                              return ProductListTile(
                                product: product,
                                onEdit: () => _openForm(product),
                                onDelete: () async =>
                                    await provider.deleteProduct(context, product.id),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}