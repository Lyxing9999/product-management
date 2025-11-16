import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/product.dart';
import '../utils/api_helper.dart';
import '../utils/api_response.dart';

class ProductService {
  final String baseUrl = 'YOUR_API_BASE_URL_MOBILE';

  ApiResponse<T> _wrapResponse<T>(
      http.Response response, T Function(dynamic json) fromJson) {
    return ApiHelper.parseResponse(response, fromJson);
  }

  // READ all products
  Future<ApiResponse<List<Product>>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    return _wrapResponse(response, (data) {
      final list = data['products'] ?? [];
      return (list as List).map((p) => Product.fromJson(p)).toList();
    });
  }

  // CREATE product
  Future<ApiResponse<Map<String, dynamic>>> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return _wrapResponse(response, (data) => data['product']);
  }

  // UPDATE product
  Future<ApiResponse<Map<String, dynamic>>> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return _wrapResponse(response, (data) => data['product']);
  }

  // DELETE product
  Future<ApiResponse<void>> deleteProduct(dynamic id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return _wrapResponse(response, (data) => null);
  }

  // SEARCH products
  Future<ApiResponse<Map<String, dynamic>>> searchProducts({
    String? name,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParameters = <String, String>{};
    if (name != null) queryParameters['name'] = name;
    if (minPrice != null) queryParameters['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParameters['maxPrice'] = maxPrice.toString();
    if (minStock != null) queryParameters['minStock'] = minStock.toString();
    if (maxStock != null) queryParameters['maxStock'] = maxStock.toString();
    queryParameters['page'] = page.toString();
    queryParameters['limit'] = limit.toString();
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortDirection != null) queryParameters['sortDirection'] = sortDirection;

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParameters);
    final response = await http.get(uri);
    return _wrapResponse(response, (data) => data);
  }

  // EXPORT CSV
  Future<void> exportCSV({Map<String, String>? filters}) async {
    final uri = Uri.parse('$baseUrl/export/csv').replace(queryParameters: filters);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/products.csv');
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(file.path);
    } else {
      throw Exception('Failed to download CSV');
    }
  }

  // EXPORT PDF
  Future<void> exportPDF({Map<String, String>? filters}) async {
    final uri = Uri.parse('$baseUrl/export/pdf').replace(queryParameters: filters);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/products.pdf');
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(file.path);
    } else {
      throw Exception('Failed to download PDF');
    }
  }
}